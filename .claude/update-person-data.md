## 웹 워크플로우 목표
- Chrome Extension으로 데이터 업데이트 자동화 목적
- 'congressman' Google Sheet 데이터를 2024년 12월 22일 이후 업데이트된 내용으로 최신화합니다.
- **하나의 매칭되는 인원에 대해서만 워크플로우를 테스트합니다.**
- **스프레드시트에서 해당 인원을 찾을 수 없으면 워크플로우를 중단합니다.**

## 참조 정보

### Groups
1. 더불어민주당
2. 국민의힘
3. 조국혁신당
4. 개혁신당
5. 진보당
6. 기본소득당
7. 사회민주당
8. 무소속

---

### ⚠️ 중요: 스크린샷 기반 분석 제거
- **절대로 screenshot을 찍거나 시각적 분석을 하지 마십시오.**
- **절대로 허락 없이 screenshot 촬영하지 말 것**
- **모든 데이터는 JavaScript 콘솔을 통해 DOM에서 직접 추출합니다.**
- **현재 어떤 Cell에 있는지 확인하려 하지마세요**
- **절대로 전체 Sheet Row 값을 추출하려하지 마세요, 상태별 처리만 따라하면 됨**
- **절대로 전체 Sheet Column 값을 추출하려하지 마세요**
- **절대로 전체 Sheet Table 값을 추출하려하지 마세요**
---

## 1단계: 나무위키 탭에서 DOM 데이터 추출

### 1-1. JavaScript를 사용한 데이터 추출
'제22대 국회희원 - 나무위키' 탭에서 **다음 JavaScript를 브라우저 콘솔에 입력**합니다:

```javascript
// ========================================
// 나무위키 데이터 추출 스크립트
// ========================================

const extractNamuWikiData = (validHeaders) => {
  const cutoffDate = new Date('2024-12-22');
  const endDate = new Date('2026-01-26');
  const records = [];

  // 올바른 데이터 테이블 찾기 (지역구, 이름, 소속, 선수, 비고 구조)
  const tables = document.querySelectorAll('table');
  const targetStatus = [
    '제명', '당연퇴직', '의원직 상실', '당선무효',
    '사퇴 후 승계', '상실 후 승계', '사퇴', '당선취소',
    '제거', '축출', '복당', '탈당'
  ];

  tables.forEach((table, tableIdx) => {
    // 테이블 헤더 확인
    const headerCells = table.querySelectorAll('thead th, tbody tr:first-child th, tbody tr:first-child td');
    const headers = Array.from(headerCells).map(h => h.textContent.trim()).join('|');

    // 올바른 구조의 테이블만 처리
    if (!validHeaders.every(header => headers.includes(header))) {
      return;
    }

    const rows = table.querySelectorAll('tbody tr');

    rows.forEach((row, rowIdx) => {
      if (rowIdx === 0) return; // 헤더 행 스킵
      const cells = row.querySelectorAll('td, th');
      if (cells.length < 5) return; // 필요한 셀이 없으면 스킵

      var status = cells[4]?.textContent.trim() || '';     // 비고
      const rowData = {
        field: cells[0]?.textContent.trim() || '',      // 지역구
        name: cells[1]?.textContent.trim() || '',       // 이름
        party: cells[2]?.textContent.trim() || '',      // 소속
        term: cells[3]?.textContent.trim() || '',       // 선수
        tableIndex: tableIdx
      };

      // 상태 필터링 (변동사항이 있는 경우만)
      var statues = status.split('*')
        .filter(s => targetStatus.some(ts => s.includes(ts)))
        
      rowData.status = statues.pop();
      const statusCheck = !!rowData.status;

      if (!statusCheck) return;

      // 비고 항목에서 날짜 추출
      const dateMatch = rowData.status.match(/\d{4}\.\d{1,2}\.\d{1,2}/);
      if (dateMatch) {
        const rowDate = new Date(
          parseInt(dateMatch[0].split('.')[0]), 
          parseInt(dateMatch[0].split('.')[1]) - 1, 
          parseInt(dateMatch[0].split('.')[2])
        );
        const dateCheck = rowDate >= cutoffDate && rowDate <= endDate;
        if (statusCheck && dateCheck && rowData.name) {
          records.push({
            ...rowData,
            date: dateMatch[0]
          });
        }
      } else if (statusCheck && rowData.name) {
        // 날짜가 없어도 상태 변동이 있으면 기록
        records.push(rowData);
      }
    });
  });

  return {
    count: records.length,
    data: records,
    timestamp: new Date().toISOString()
  };
};

const extractAreaPersons = () => extractNamuWikiData(['지역구','이름','소속','선수','비고']);
const extractNoAreaPersons = () => extractNamuWikiData(['순번','이름','소속','선수','비고']);
const extractPersons = () => ({
  count: [...extractAreaPersons().data, ...extractNoAreaPersons().data].length,
  data: [...extractAreaPersons().data, ...extractNoAreaPersons().data]
});

// 실행 및 출력
const result = extractPersons();
console.log('=== 추출 결과 ===');
console.log(JSON.stringify(result, null, 2));

// 결과 기억
```

- ***Javascript로 처리할 수 없는 경우: 4.1.1 지역구, 4.2 비례대표 확인하고 개선된 Javascript 출력***

### 1-2. 추출된 데이터 확인
- 콘솔에 출력된 데이터를 검토합니다.
<!-- - `result.data` 배열에서 첫 번째 인원 정보를 확인합니다 (테스트용). -->
- 예시:
  ```json
  {
    "name": "홍길동",
    "party": "더불어민주당",
    "field": "서울 강남구",
    "status": "사퇴 후 승계",
    "date": "2024.12.25"
  }
  ```

---

## 2단계: `사퇴`, `당선무효`, `상실`, `탈당`, `입당`, `제명`, `복당` 인 경우 Google Sheets 탭에서 해당 인원 찾기
- **read_page로 화면 분석 금지**
- ***현재 어느 Cell에 있는지 확인 금지***

### 2-1. 인원 검색
- ** 나무위키 Dom 결과에 나오지 않은 인원 검색 금지**
- Cmd + F를 사용하여 검색 창을 염
- 나무위키에서 복사한 **인원 이름**을 PASTE
- **Enter 안눌러도 즉시 검색됨**

### 2-2. 인원 확인
- Esc 키를 눌러서 검색 창을 닫습니다
- Cmd + C를 사용하여 현재 **Cell**을 복사합니다.
- 복사된 Cell의 값이 나무 위키에서 복사한 인원 이름과 같은지 확인: clipboard.readText()
- **같지 않으면 워크플로우를 중단합니다**
- **절대 전체 Row 값을 추출하려하지 마세요**
- **read_page로 화면 분석 금지**

---

## 3단계: 상태별 처리 (Google Sheets 업데이트)

### 3-1. 상태 판별
1단계에서 추출한 데이터의 **status** 필드 확인:

| Status | 처리 방식 | 설명 |
|---|---|---|
| `사퇴`, `당선무효`, `상실` 등 (퇴직) | **행 제거** | 해당 인원 행을 삭제 |
| `사퇴 후 승계`, `상실 후 승계` (승계) | **행 추가** | 새로운 인원 행을 추가 |
| `탈당`, `입당`, `제명`, `복당` (당변) | **그룹 ID 변경** | 기존 행의 그룹 ID만 수정 |

### 3-2. 처리: 행 제거 (퇴직 인원)
만약 status가 `사퇴`, `당선무효`, `상실` 포함이면:
- 메뉴 열기: Ctrl + Option + E
- 삭제 선택: D
- 행 삭제 선택: D

### 3-3. 처리: 행 추가 (승계 인원)
만약 status가 `사퇴 후 승계`, `상실 후 승계` 이면:

- 마지막 행으로 이동: Cmd + ↓
- 첫 Column으로 이동: Home
- name 칸으로 이동: Right
- name 입력: 붙여넣기
- no 칸으로 이동: Left
- no 입력: =, Up, + 1, Enter
- 추가 중인 Row로 이동: Up
- group 칸으로 이동: Right, Right, Right
- group 입력: 나무 위키에서 찾은 `소속`와 일치하는 Group ID(Groups에서 찾음)
- field 칸으로 이동: Right
- field 입력: 나무 위키의 `지역구` 값

### 3-4. 처리: 그룹 ID 변경 (당변 인원)
만약 status가 `탈당`, `제명` 포함이면:
- group 칸으로 이동: Right, Right
- group 입력: 8 (Groups의 `무소속` ID)

### 3-5. 처리: 그룹 ID 변경 (당변 인원)
만약 status가 `입당`, `복당` 포함이면:
- group 칸으로 이동: Right, Right
- group 입력: 나무 위키에서 찾은 `소속`와 일치하는 Group ID(Groups에서 찾음) Enter

---

## 4단계: 다음 데이터 처리 (반복)

## 📋 체크리스트

- [ ] 1단계: JavaScript로 나무위키 데이터 추출 완료
- [ ] 1-3: 첫 번째 인원 정보 확인 (테스트용)
- [ ] 2단계: Google Sheets에서 해당 인원 찾기 완료
- [ ] 2-2: 인원 존재 여부 확인 (없으면 중단)
- [ ] 3단계: 상태에 따른 처리 (삭제/추가/변경) 완료
- [ ] 4단계: 스크롤 후 반복 (필요시)

---

## 🔧 주요 개선사항

| 항목 | 기존 | 개선 | 효과 |
|---|---|---|---|
| 데이터 추출 | Screenshot OCR | DOM JavaScript | **3배 빠름** |
| 검색 | Command+F (UI) | API 프로그래밍 | **2배 빠름** |
| 행 조작 | UI 클릭 | JavaScript API | **일관성 증가** |
| 오류 처리 | 수동 | 자동 필터링 | **휴먼 에러 감소** |

---

## ❌ 절대 금지 사항

- ❌ `screenshot` 찍기
- ❌ `Command + F` 사용 (나무위키 탭만 금지)
- ❌ 위로 스크롤하기 (나무위키 탭)
- ❌ 시각적 분석에 의존
- ❌ 이름 수동 입력 (항상 복사-붙여넣기)
- 주어진 Javascript 실패 시 중단, 추가 Javascript 작성

---

## ✅ 필수 사항

- ✅ 모든 데이터 추출은 **JavaScript DOM 파싱**
- ✅ 모든 필터링은 **프로그래밍적**
- ✅ 테스트는 **첫 번째 인원 1개만**

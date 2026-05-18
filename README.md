## 소개
앱스토어에 출시되어 운영 중인 스포츠 정보 검색 및 데이터 탐색 iOS 앱입니다.
사용자는 축구, NBA, KBO, MLB, 테니스 등 다양한 스포츠 리그의 선수·팀 정보, 경기 일정, 순위, 실시간 경기 기록, 토너먼트 대진표 등을 키워드 기반으로 검색하고 탐색할 수 있습니다.

기존 스포츠 정보 제공 서비스의 카테고리 중심 구조로 인해 원하는 정보를 찾기까지 여러 단계를 거쳐야 하는 불편함을 줄이고, 검색 중심의 간결한 탐색 경험을 제공하고자 만들었습니다.

## 주요 기능
- [선수/팀/리그 + 스포츠 키워드 + 시즌] 검색어를 통한 통합 검색
- Trie 기반 자동완성 검색
- 인기 검색어 및 리그별 키워드를 통한 검색
- 축구, NBA, KBO, MLB, 테니스 등 다양한 리그 데이터 지원
- 선수·팀 정보 / 선수·팀 스탯 / 선수·팀 순위 화면 제공
- 리그 일정 / 선수·팀 일정 / 경기 상세 기록 / 토너먼트 대진표 화면 제공
- 새로고침을 통한 실시간 경기 데이터 제공

## 스크린샷
<img width="19%" alt="app_store_v1 0 9_1" src="https://github.com/user-attachments/assets/c97a36d5-2f2b-4f2f-8b97-3bfcabf7810a" />
<img width="19%" alt="app_store_v1 0 9_2" src="https://github.com/user-attachments/assets/19e12b80-07d1-479a-ad2e-546d6db0c10a" />
<img width="19%" alt="app_store_v1 0 9_3" src="https://github.com/user-attachments/assets/d4a06b4c-c349-48da-ad02-9aee27edf6fc" />
<img width="19%" alt="app_store_v1 0 9_4" src="https://github.com/user-attachments/assets/cee6d916-9fa2-494b-9f13-8916b4058d2a" />
<img width="19%" alt="app_store_v1 0 9_5" src="https://github.com/user-attachments/assets/bb5bb6b9-73f6-432d-8d24-ba0b65b8c793" />

## 기술 스택
- Swift
- SwiftUI,
- The Composable Architecture(TCA)
- Swift Concurrency (async/await)
- URLSession
- REST API
- AWS SDK

## 구조
SwiftUI와 The Composable Architecture(TCA)를 기반으로 프로젝트를 구성하였으며,  
화면 UI, 상태 관리, 네비게이션, 데이터 모델, 네트워크 통신 로직을 역할별로 분리했습니다.

- AppStore(Reducer) - 앱 전역 상태와 네비게이션 스택을 관리하며, 검색 결과에 따른 종목별 상세 화면 라우팅 처리

- SearchStore(Reducer) - 검색어 입력, 자동완성, 인기 검색어, 리그별 키워드, 검색 결과 상태 및 액션 관리

- Feature Stores(Reducer) - 축구, NBA, KBO, MLB, 테니스 등 종목별 화면의 상태와 액션을 관리

- Base Stores(Reducer) - 정보, 일정, 스탯 등 유사한 화면에서 반복되는 상태 관리 로직을 공통화하여 재사용

- View - SwiftUI 기반 화면 구성 및 사용자 인터랙션 처리

- ViewContainer - 유사한 화면 구조를 공통화하여 종목별 UI 구현 중복을 줄이고 재사용성 관리

- DataModel - 다양한 형태의 스포츠 API 응답을 공통 데이터 모델로 수신하고, 종목과 데이터 타입에 따라 화면별 모델로 변환

- SearchClient - 검색, 일정, 키워드, ID 기반 조회 등 스포츠 데이터 API 요청 처리

- APIEndpoint - API URL, HTTP Method, Request Body, Query Parameter 구성 중앙화

- Utilities - 자동완성 Trie, 캘린더 기반 날짜·시즌 계산, 공통 포맷팅 등 앱 전반에서 사용하는 유틸리티 관리

## 개선 중인 작업
아래 작업들은 별도 브랜치에서 점진적으로 개선 중

1. **테스트 코드 도입**  
Branch: `improvement/test-code`
 
- Swift Testing과 TCA `TestStore`를 활용한 테스트 코드 작성
- `SearchStore`의 Action에 따른 State 변경 검증
- 테스트 환경에서 네트워크 의존성을 대체할 수 있도록 `SearchClient` 의존성 주입 구조 개선

## 기술적 의사결정
### KarrotCodableKit 도입 검토
API 응답 모델의 디코딩 구조를 개선하기 위해 [KarrotCodableKit](https://github.com/daangn/KarrotCodableKit) 도입을 검토함

기대했던 이점은 크게 두 가지였음
1. 대부분의 스포츠 응답 모델에 반복적으로 작성되어 있는 `CodingKeys` 정의 단순화
2. 동일한 JSON 필드에 다양한 형태로 내려오는 응답 데이터를 더 명확하고 안전하게 분기 처리. 특히 검색 메인 모델인 `DataModel`은 `dataType`값에 따라 `data`필드를 서로 다른 응답 모델로 디코딩하고 있었기 때문에, 이 분기 구조를 더 타입 안정적으로 개선하기를 기대

다음과 같은 문제로 적용하기 어렵다고 판단
1. 현재 일부 모델은 단순히 property name을 snake_case JSON 필드와 매핑하는 구조가 아니라, `_id`, `_name`처럼 별도의 backing property를 두고 실제 JSON 필드와 매핑한 뒤 computed property로 기본값을 제공하는 방식으로 작성되어 있음. 반면 `KarrotCodableKit`의 `codingKeyStyle`은 property name을 기준으로 `.default`또는 `.snakeCase`형태의 coding key를 생성하는 방식이기 때문에, 현재 구조를 크게 단순화하기 어려웠음






































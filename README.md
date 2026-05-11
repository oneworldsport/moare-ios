## 소개
앱스토어에 출시되어 운영 중인 스포츠 정보 검색 및 데이터 탐색 iOS 앱입니다.
사용자는 축구, NBA, KBO, MLB, 테니스 등 다양한 스포츠 리그의 선수·팀 정보, 경기 일정, 순위, 실시간 경기 기록, 토너먼트 대진표 등을 키워드 기반으로 검색하고 탐색할 수 있습니다.

기존 스포츠 정보 제공 서비스의 카테고리 중심 구조로 인해 원하는 정보를 찾기까지 여러 단계를 거쳐야 하는 불편함을 줄이고, 검색 중심의 간결한 탐색 경험을 제공하고자 만들었습니다.

## 주요 기능
- "선수/팀/리그 + 스포츠 키워드 + 시즌" 검색어를 통한 통합 검색
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
SwiftUI와 TCA 기반으로 프로젝트를 구성하였으며, 

- `AppStore`: 앱 전역 네비게이션 및 Path 관리
- `SearchStore`: 검색어, 자동완성, 인기 검색어, 검색 결과 상태 관리
- `SearchClient`: 검색/일정/키워드/ID 기반 API 호출
- `APIEndpoint`: API URL, HTTP Method, Body 구성 중앙화
- `DataModel`: Raw API 응답을 종목별 DisplayModel로 변환
- `Feature Stores`: 축구/NBA/KBO/MLB/테니스 화면별 상태 및 액션 관리

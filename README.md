# OpenMarket
## Information
* 프로젝트 기간 : 2021.08.08. ~ 2021.08.20.
* 프로젝트 인원 : 3명 Marco(@Keeplo), Nala(@jazz-ing), Yun(@blanche37)
* 프로젝트 소개 
    > 구현된 서버 API를 이용해서 네트워크 통신으로 서버에 저장된 오픈마켓 데이터를 보여주는 커뮤니티 앱
* Pull Requests
    * [Step 1](https://github.com/yagom-academy/ios-open-market/pull/63)  
    
-> 해당 프로젝트는 모델 구현 및 데이터 파싱, UnitTest 과정까지만 진행했습니다.

### Tech Stack
* Swift 5.4
* Xcode 12.5
* iOS 14.0

## Demo
<details><summary>UML</summary><div markdown="1">
    
![68747470733a2f2f692e696d6775722e636f6d2f784379457432342e706e67-2](https://user-images.githubusercontent.com/24707229/152350614-49cceb9f-9edf-4355-a7a6-f3c224eec4ac.png)
</div></details>

## Troubleshootings
<details><summary>모델 타입의 유형 선택 class vs struct</summary><div markdown="1">

**최초 아이디어**

두 화면 (리스트를 그려주는 화면과 조회하는 화면)에서 `Item` 인스턴스를 주고 받으면서(하나의 인스턴스를 참조) 인스턴스의 정보를 공유하기 위해 `class`로 구현하려고 함.

**모델 타입에 관한 고민**

실시간 데이터 변화를 인지하기 위해서 각 화면에 접근시 매번 데이터를 업데이트하는게 좋다고 생각함 (서버와 동기화), `id` 정보만 전달

⇒ `Item` 인스턴스의 참조가 필요없어짐

⇒ 모델 타입을 `struct`로 구현하기로 변경함.
</div></details>
<details><summary>네트워킹을 담당하는 객체의 생명주기 관련 고민</summary><div markdown="1">
    
**PR 과정에서 리뷰어와 고민한 내용**

> Q : 왜 네트워크 담당하는 녀석이 각 화면마다 인스턴스로 있는 것보다, 싱글턴이나 타입 프로퍼티 구조체 인게 낫다고 생각했나요?  

A : 통신을 위한 인스턴스가 각 화면에 할당되어 메모리 점유하는 건 불 필요할 것 같다고 생각, 하나의 통신 인스턴스가 통신하는 동작에 한해서 해당 블록과 completion 블록이 비동기로 처리가 보장됨

![Untitled-3](https://user-images.githubusercontent.com/24707229/152350704-d4fb2d32-5a18-4160-9d63-5bef3b878f57.png)
![Untitled-2](https://user-images.githubusercontent.com/24707229/152350713-08bb0fab-09d9-48b4-ad08-b3a506400bc6.png)
[출처 Apple Documentation URLSession](https://developer.apple.com/documentation/foundation/urlsession)

> Q : 두 가지 방법의 장단점이나 차이가 무엇이라고 생각하나요?

A : 
- 싱글턴
    - 장점 - 엑세스가 편함, 공유 인스턴스의 메모리 공유
    - 단점 - 공유 인스턴스에 엑세스 위치가 많을 수록 앱 동작 예측이 어렵고 싱글톤의 전역 상태와 동기화 하는게 어려워짐 (안티 패턴의 원인)
- 구조체 타입 프로퍼티 & 타입 메서드
    - 장점 - 엑세스가 편함, 공유 인스턴스의 메모리 공유
    - 단점 - 해당 타입을 인스턴스화가 가능해짐.. 해당 타입을 타입 프로퍼티, 메서드로만 쓸 건지, Shared Instance로 쓸 건지 정해야함?!(위에 언급된 "공유 인스턴스" 와 다른 [Shared Instance](https://www.donnywals.com/whats-the-difference-between-a-singleton-and-a-shared-instance-in-swift/)라는 표현을 발견하고 공부했는데 이런 형태를 의미 함.

**서버와 통신을 담당하는 NetworkingManager 타입의 구현 방식 고민함**  
화면 별 구조체 인스턴스 생성 VS 싱글턴 VS 타입 메서드

→ **싱글턴으로 구현** 
네트워킹을 담당하는 인스턴스는 하나만 존재하는 것이 더욱 적절하다고 판단 
싱글턴과 타입 메서드에 대해 오래 고민했으나 메모리 점유의 측면에서 싱글턴으로 결정

![Untitled](https://user-images.githubusercontent.com/24707229/152350962-10b3d030-3652-46fb-bc9f-2e9b74db7219.png)
[출처 Apple Documentation Managing shared Resource Using a Singleton](https://developer.apple.com/documentation/swift/cocoa_design_patterns/managing_a_shared_resource_using_a_singleton)

→ 애플에서 예시로 싱글턴을 사용하는 상황을 언급함. 특별한 단점을 찾기전까지 싱글턴으로 구현해보기로 결정
</div></details>
<details><summary>공유 인스턴스와 Singleton Pattern 관련 이해</summary><div markdown="1">

- `공유 인스턴스` 의 이해 - static 저장 프로퍼티로 할당된 인스턴스로, 전역에서 사용가능하고, 일반적으로 shared 라는 이름의 타입 프로퍼티로 정의함.
- `Singletone Pattern` : 이런 *공유 인스턴스*를 하나 가지며, 최초 할당된 싱글턴 인스턴스 이외에 추가적인 인스턴스를 생성하지 못함
- `Shared Instance` 의 사용 클래스 : *공유 인스턴스*(타입 프로퍼티)이외의 특정 설정이나 특징을 가진 인스턴스를 다양하게 생성 및 사용해서, 각 기능에 최적화된 동작을 하게 하는 장점을 가짐 [Article](https://drewag.me/posts/2019/09/03/singletons-and-shared-instances-in-swift)
    
    > (위 설명에서 공유 인스턴스 ≠ Shared Instance)
</div></details>
<details><summary>통신 관련 객체 UnitTest 구현 - Mock 객체</summary><div markdown="1">

- MockURLSession 과 MockURLSessionDataTask등 Mock 객체를 생성해서 통신 상황을 테스트  
    → 통신 성공과 실패 과정을 `isSuccess` 프로퍼티 초기화 주입으로 결정
    ```swift
    func test_success_통신이성공했을때유효한URL이면_JSON데이터반환한다() {
            //given
            let request = URLRequest(url: URL(string: NetworkHandler.OpenMarketInfo.baseURL +  NetworkHandler.OpenMarketInfo.getList.makePath(suffix: 1))!)
            let manager = NetworkHandler(urlSession: MockURLSession(isSuccess: true))
            var check = false
            //when
            manager.request(bundle: request) { result in
                guard case .success(_) = result else {
                    return
                }
                check = true
            }
            //then
            XCTAssert(check)
        }
    ```
- JSON 디코딩 유닛테스트   
    → Mock 파일(.json 파일)로 생성된 인스턴스의 정보를 해당 정보 문자열과 직접비교   
    → 위 방식은 하드코딩 성향이 강함 테스트 방법에 대해 공부 필요성을 느낌   
</div></details>
<br>

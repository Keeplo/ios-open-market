## iOS 커리어 스타터 캠프

### 오픈마켓 프로젝트 저장소

# 🛒 오픈마켓 프로젝트
**기 간 : 2021.08.09 ~ 2021.08.27**  
**팀 원 : Marco([keeplo](https://github.com/Keeplo)), Yun([blanche37](https://github.com/blanche37)), Nala([jazz-ing](https://github.com/jazz-ing))**

### Index
[UML](#UML)  
[STEP1-1](#STEP1-1단계)  
[STEP1-2](#STEP1-2단계)  

# UML
![](https://i.imgur.com/xCyEt24.png)

# STEP1 1단계
**JSON 파싱 및 네트워크 통신 무관 테스트**
## 📝 새롭게 알게된 개념
* **ISO 4217**
    * API에 표기된 "ISO 4217을 따름" 은 무엇인가?
        제정된 통화의 이름을 정의하기 위한 3문자의 부호(통화코드)를 기술하는 국제표준화 기구(ISO)가 정의한 국제 기준 [위키백과](https://ko.wikipedia.org/wiki/ISO_4217)
<details><summary>예제코드</summary>
<div markdown="1">

```swift
let krPrice = 1290000
let usPrice = 1690
        
let formatter = NumberFormatter()
formatter.numberStyle = .currency
        
        
formatter.currencyCode = "KRW"
        
let krNumber = NSNumber(value: krPrice)
print(formatter.string(from: krNumber)!)
        
formatter.currencyCode = "USD"
        
let usNumber = NSNumber(value: usPrice)
print(formatter.string(from: usNumber)!)
```
![](https://i.imgur.com/Ld73hjA.png)

</div></details>
        
* **UNIX Timestamp**
    * API에 표기된 "UNIX TimeStamp"의 의미는?
        Unix Time은 시각을 나타내는 방식으로, 1970년 1월 1일 00:00:00 협정 세계시(UTC)부터의 경과 시간을 초로 환산하여 정수로 나타낸 것 [위키백과](https://ko.wikipedia.org/wiki/%EC%9C%A0%EB%8B%89%EC%8A%A4_%EC%8B%9C%EA%B0%84)
    

<details><summary>예제코드</summary><div markdown="1">

```swift
let epochTime = TimeInterval(1611523563.7237701)

let myDate = Date(timeIntervalSince1970: epochTime)
print("Converted Time \(myDate)")
```
</div></details>

* **keyDecodingStrategy**
    `JSONDecoder().keyDecodingStrategy = .convertFromSnakeCase`
    * snake-case key를 camel-case key로 전환해주는 JSONDecoder의 속성
    * CodingKey를 채택한 enum을 별도로 선언하지 않아도 됨
* **Bundle 객체 호출**
    `Bundle(for: type(of: self)).path(forResource: "Items", ofType: "json")`
    * 앱 프로젝트가 아닌 UnitTest 범위에 Bundle 객체를 호출하는 방법
    * 해당 인스턴스(self)를 포함한 Bundle 객체를 호출함
* **모델 타입의 유형 선택 `class` vs `struct`**
    * 최초 아이디어에서는 리스트를 그려주는 화면과 조회하는 화면에서 `Item` 모델을 주고 받으면서(하나의 인스턴스를 참조) 해당 인스턴스의 정보를 업데이트하기 위해 `class`로 구현하려 했음![](https://i.imgur.com/wuW0HhV.png)
    * 리스트를 그려주는 페이지는 방문할 때마다 다시 통신해서 업데이트 하는게 좋음 (서버와 동기화),
상품 조회 화면에서 `id` 기반으로 새로운 데이터를 받아옴  
-> 모델의 참조가 필요 없어짐  
-> `struct`로 구현하기로 변경  
<details><summary>처음 API 해석하면서 고민해본 모델 구조</summary><div markdown="1">

* ![](https://i.imgur.com/F8oAtvM.png)
* ![](https://i.imgur.com/uJaAveu.png)
</div></details>

## 🤔 고민한 내용
* **Date 타입**  
    모델은 해당 데이터를 Date 타입 같은 형태로 포함할 것인가?  
        **-> 앱 전반에서 사용하지 않음, Double 저장 프로퍼티**
* **NumberFormatter**  
    초기화 단계에서 필요한 형태의 NumberFormmater 설정을 만들어 저장프로퍼티로 가지기 VS 기본 정보는 저장프로퍼티로 가지고 연산 프로퍼티 형태로 형태 정보 반환해주기  
    **-> 각 데이터를 저장 프로퍼티로 가지고 타입 연산 프로퍼티(NumberFormatter)로 해당 정보 보여주기**  
* **JSONDecoder의 초기화 위치**  
    JSON파일을 파싱할 때 사용할 `parse()`메서드 구현 시, JSONDecoder의 인스턴스 생성 위치  
    **-> 메모리 점유의 측면에서 고민해보았으나 아직 어떤 방법이 가장 효율적인지 결정하지 못했음**
    ```swift
    struct ParsingManager {
        // 1. 타입의 프로퍼티로 생성
        let decoder = JSONDecoder()
        
        func parse() {
            // 2. 메서드 내부 지역변수로 생성
            let decoder = JSONDecoder()
        }
    }
    
    // 3. 디코딩이 필요할 때만 생성
    JSONDecoder().decode()
    ```
* **Date 타입 사용하기?**  
    시간을 나타내는 `registrationDate` 프로퍼티의 타입을 Date 타입으로 미리 초기화를 해둘지, 연산프로퍼티 사용할지   
    **-> 다양한 방향으로 사용 될 수 있는 데이터를 초기화 과정에서 Date 타입으로 할당하는 건 제한적임, JSON 데이터와 다른 타입으로 해석에 혼동될 수 있음**
    ```swift
    // 기존 아이디어
    struct Item: Decodable {
       // ...
         let registrationDate: Date

         private enum CodingKeys: String, CodingKey {
             case registrationDate // , ...
         }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                    // ... 	
            let epochTime = try container.decode(Double.self, forKey: .registrationDate)
            self.registrationDate = Date(timeIntervalSince1970: epochTime)
        }
    }
    // 연산 프로퍼티를 이용해서 필요할때만 해당 정보를 변형해서 추출하기
    struct Item: Decodable {
         // ...
         let registrationDate: Double
         // 값을 표현해줄 연산프로퍼티 
         var dateInstance: Date {
                let instance = Date(timeIntervalSince1970: self.registrationDate)
                return instance
         }
    }
    ```

</br>

# STEP1 2단계
**서버와 실제 데이터 주고 받기**
## 📝 새롭게 알게된 개념
* **Result 타입**
    * 단순히 옵셔널 처리를 해주지 않고, 함수의 결과를 성공과 실패의 경우를 나누어 처리해주기 위해 Result 타입을 사용함
    ```swift
    func request(bundle request: URLRequest, completion: @escaping (Result<Data, Error>) -> ()) {
        let dataTask = session.dataTask(with: request) { data, response, error in
            // ...
            guard let data = data else {
                completion(.failure(NetworkingManagerError.failRequestByData))
                return
            }
            completion(.success(data))
        }
        dataTask.resume()
    }
    ```
* **escaping closure**
     * 매개변수로 전달받은 클로저를 함수 밖으로 전달하는 경우에, `@escaping` 키워드를 붙여주지 않으면 컴파일 오류가 난다.
    ```swift
    var resumeDidCall: () -> () = { }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        ///생략
        guard let data = jsonData else {
            mockURLSessionDataTask.resumeDidCall = { completionHandler(nil, failure, nil) }
            return mockURLSessionDataTask
        }
        
        return mockURLSessionDataTask
    
    }
    ```
* **HTTP Method**
    * HTTP (Hypertext Transfer Protocol) : 데이터를 주고 받기위한 하나의 통신 규약
    * HTTP Method : 서버에 요청하는 Request 형태 또는 종류 (GET, POST, PUT, DELETE, PATCH 등)
    * HTTP Status Code : 서버에 보낸 요청에 대한 응답에 담긴 상태 정보
* **Mock 객체**
    * Test Double : 테스트를 진행하기 어려운 경우 이를 대신해 테스트를 진행할 수 있도록 만들어 주는 객체(Stub, Spy, Mock, FakeObject 등)
    * Mock 객체 : 동일한 이름의 메서드 또는 프로퍼티를 포함해서 내용에 따라 동작하도록 프로그래밍 된 객체  
    **-> 프로토콜을 이용해서 테스트하고 싶은 메서드를 Mock 객체에 동일하게 생성함**
    ```swift
    protocol URLSessionProtocol {
        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    }
    // 실제 사용할 객체
    extension URLSession: URLSessionProtocol { 
        // 통신 없는 테스트를 하고싶은 메서드
        // func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    } 
    // 테스트를 위한 Mock 객체
    class MockURLSession: URLSessionProtocol {}
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask { }
    }

    ```
* **공유 인스턴스와 Singleton Pattern**
    * *공유 인스턴스*는 static 저장 프로퍼티로 할당된 인스턴스로, 전역에서 사용가능하고, 일반적으로 shared 라는 이름의 타입 프로퍼티로 정의함.
    * Singleton Pattern : 이러한 *공유 인스턴스*를 하나 가지며, 추가적인 인스턴스를 생성하지 못함
    * Shared Instance 의 사용 클래스 : *공유 인스턴스*(타입 프로퍼티)이외의 특정 설정이나 특징을 가진 인스턴스를 다양하게 생성 및 사용해서, 각 기능에 최적화된 동작을 하게 하는 장점을 가짐 [Article](https://drewag.me/posts/2019/09/03/singletons-and-shared-instances-in-swift) 
        > (위 설명에서 *공유 인스턴스* ≠ Shared Instance)

## 🤔 고민한 내용
* **서버와 통신을 담당하는 NetworkingManager 타입의 구현 방식**  
    화면별 인스턴스 생성 VS 싱글턴 VS 타입 메서드  
    **-> 싱글턴으로 구현. 네트워킹을 담당하는 인스턴스는 하나만 존재하는 것이 더욱 적절하다고 판단했음. 싱글턴과 타입 메서드에 대해 오래 고민했으나 메모리 점유의 측면에서 싱글턴으로 결정.**  
    **-> Apple의 [Article](https://developer.apple.com/documentation/swift/cocoa_design_patterns/managing_a_shared_resource_using_a_singleton)에서는 Singleton 사용의 대표적인 사례로 Network Manager를 이야기하고 있음**
* **Request API 구현**  
    통신 상황의 정보(HTTPMethod, path, body)를 담은 사용자 타입을 구현했음. 통신에 대한 다양한 정보를 담거나 확장성을 고려했을 때 enum보다 struct로 구현하는 것이 더욱 적절하다고 생각해 별도로 구현하였음.
* **UnitTest 구현**  
    * MockURLSession 과 MockURLSessionDataTask등 Mock 객체를 생성해서 통신 상황을 테스트  
        * 통신 성공과 실패 과정을 `isSuccess` 프로퍼티 초기화 주입으로 결정  
    * JSON 디코딩 유닛테스트  
        * Mock 파일(.json 파일)로 생성된 인스턴스의 정보를 비교  

## 𝑄 PR 과정에서 받은 질문
1.  **왜 네트워킹 담당하는 녀석이 각 화면마다 인스턴스로 있는 것 보다, 싱글턴이나 구조체인게 낫다고 생각했나요?**  
    𝑨  
    * 인스턴스 여러개면 그만큼 메모리 점유가 많아지는데, 하나의 인스턴스로 통신 동작으로 모두 처리해도 좋을 것 같다고 생각함
    * 이어서 하나의 인스턴스가 통신하는 동작에 한해서 해당 블록과 completion 블록이 비 동기로 처리가 보장되고 같은 URLSession 인스턴스라면 같은 자원에 접근에 대해서 Thread-Safety 까지 보장하기 때문에 여러개일 필요가 없다고 생각함.

    ![](https://i.imgur.com/cuUjME3.png)
    [Apple Documentation URLSession 1](https://developer.apple.com/documentation/foundation/urlsession)


    ![](https://i.imgur.com/0idkXBc.png)
    [Apple Documentation URLSession 2](https://developer.apple.com/documentation/foundation/urlsession)

2.  **두 가지 방법의 장단점이나 차이가 무엇이라고 생각하나요?!**  
    𝑨   
    - 싱글톤
        - 장점 - 엑세스가 편함, 공유 인스턴스의 메모리 공유
        - 단점 - 공유 인스턴스에 엑세스 위치가 많을 수록 앱 동작 예측이 어렵고 싱글톤의 전역 상태와 동기화 하는게 어려워짐 (안티 패턴의 원인)
    - 구조체 타입 프로퍼티 & 타입 메서드
        - 장점 - 엑세스가 편함, 공유 인스턴스의 메모리 공유
        - 단점 - 해당 타입을 인스턴스화가 가능해짐.. 해당 타입을 타입 프로퍼티, 메서드로만 쓸 건지, Shared Instance로 쓸 건지 정해야함?!(위에 언급된 "공유 인스턴스" 와 다른 [Shared Instance](https://www.donnywals.com/whats-the-difference-between-a-singleton-and-a-shared-instance-in-swift/)라는 표현을 발견하고 공부했는데 이런 형태를 의미 함. 
    - 고민 후 결정된 방향... (feat. 실마리..)
    ![](https://i.imgur.com/fLzzqxG.png)
        [출처 Apple Documentation](https://developer.apple.com/documentation/swift/cocoa_design_patterns/managing_a_shared_resource_using_a_singleton)

        → ps. 애플에서 예시로 싱글톤을 사용하는 상황을 언급하고 있음. 특별한 단점을 찾기 전까지는 싱글톤으로 구현하기로 결정함.

3. **값 복사보다 참조가 메모리 할당을 줄이나요?**  
    𝑨   
    값 복사는 해당 객체 자체를 복사해서 동일한 메모리를 점유하지만,  
    참조를 하는 경우는 스택 영역에 참조되는 객체의 주소를 저장하므로 실제 객체 1개만큼만 메모리를 점유함.



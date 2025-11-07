# wanna_do_public

워너두 앱 포트폴리오 소개 및 설명링크: 
https://marvelous-cantaloupe-01b.notion.site/86cca8895735425db84a7084f8b19e0f?v=a50dcc5fe3e74fa9a31aa962d39a5c15&source=copy_link


flutter 파일 구성
📂 lib/

- 앱 주요 화면 구성에 필요한 공용 위젯 및 페이지 뷰 관리
🧩 component
challenge_page_view.dart
challenges_home.dart
challenges_page_view.dart
main_page.dart
start_guide.dart
start_login.dart
unable_main_page.dart
wanna_login.dart

- 프로젝트 전역에서 사용하는 상수 및 색상 정보 관리
⚙️ const
colors.dart
example_context.dart

- 주요 기능(화면 단위)별 위젯 구조 관리
🗂 container
challenge/
challenge_detail/
checkup/
help/
my_challenge/
point/
public/
rank/
setting/
space/
main_checkup.dart
main_home.dart
main_my.dart
main_space.dart

- 상태 관리용 컨트롤러
🧠 controller
page/
firebase_messaging_service.dart
init_controller.dart
timer_controller.dart
user_controller.dart

- 데이터 모델 정의 (API, DB, 로컬데이터 매핑용)
🧾 model
challenge/
challenge_model.dart
checkup/
checkup_log_model.dart
request_queue_model.dart
log/
point/
report/
service/
space/
statistic/
user/

- 단일 페이지 UI 화면
🖥 screen
home_screen.dart

- 앱 전역 스타일 및 위젯별 디자인 설정
🎨 style
appbar_style.dart
button_style.dart
dialog_style.dart
list_item_style.dart
loading_style.dart
text_style.dart
toast_style.dart

- Firebase 및 프로젝트 유틸리티 설정 파일
🧰 util
firebase_options.dart

- Flutter 애플리케이션 진입
main.dart


Firebase 백엔드 로직을 위한 Node.js 기반 함수 폴더
☁️ functions
.gitignore
index.js
package.json
package-lock.json

# worksafe_app

A new Flutter project.

## 필수 설정 (처음 클론한 사람을 위한 안내)

이 저장소를 클론한 직후에는 **`.env` 파일이 없어서 빌드가 실패합니다.**
`.env` 에는 Gemini API 키가 들어 있어, 키 보호를 위해 `.gitignore` 로 제외했기 때문입니다.

다음 순서대로 설정하세요.

1. 프로젝트 루트에서 예시 파일을 복사합니다.

   ```bash
   cp .env.example .env
   ```

2. 생성된 `.env` 를 열어 `GEMINI_API_KEY` 에 본인의 Gemini API 키를 넣습니다.

   ```
   GEMINI_API_KEY=여기에_본인_키
   ```

3. 키 발급: https://aistudio.google.com/apikey

> `.env` 는 절대 커밋하지 마세요. 이미 `.gitignore` 에 등록되어 있습니다.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

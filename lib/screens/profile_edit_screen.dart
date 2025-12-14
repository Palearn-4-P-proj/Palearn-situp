import 'package:flutter/material.dart';
// 📌 서버 통신 시 http, dio 등이 필요함
// import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController emailCtrl;
  late TextEditingController nameCtrl;
  late TextEditingController birthCtrl;
  late TextEditingController pwCtrl;
  late TextEditingController pw2Ctrl;

  // ▶ 프로필 정보 — 서버에서 GET으로 받아와서 업데이트해야 할 부분
  String userId = '25030024';

  File? _pickedImage;
  String photoUrl =
      'https://images.unsplash.com/photo-1603415526960-f7e0328d13a2?w=256&h=256&fit=crop';

  final ImagePicker _picker = ImagePicker();

  bool hidePw = true;
  bool hidePw2 = true;
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
      // ============================================================
      // 🟦 BACKEND TODO (이미지 업로드)
      //
      // [요청]
      // - 선택한 이미지 파일을 서버(S3)에 업로드
      // - 업로드 후 접근 가능한 image URL 반환
      //
      // [API 예시]
      // POST /upload/profile-image
      // Content-Type: multipart/form-data
      //
      // form-data:
      // - file: <이미지 파일>
      // - user_id: "25030024"
      //
      // [응답 예시]
      // {
      //   "photo_url": "https://s3.amazonaws.com/.../profile.jpg"
      // }
      //
      // [Flutter 처리]
      // - 응답으로 받은 photo_url을 photoUrl 변수에 저장
      // - setState(() { photoUrl = 응답값; })
      //
      // ⚠️ 주의:
      // - 지금은 로컬 미리보기(FileImage)만 보여주는 상태
      // - 서버 업로드 완료 후에는 photoUrl 기반 NetworkImage로 전환 필요
      // ============================================================
    }
  }

  @override
  void initState() {
    super.initState();
    emailCtrl = TextEditingController(text: 'example@example.com');
    nameCtrl = TextEditingController(text: 'John Smith');
    birthCtrl = TextEditingController();
    pwCtrl = TextEditingController();
    pw2Ctrl = TextEditingController();

    // =========================================================================
    // 🟦 [중요] 프로필 초기 데이터 불러오기 — FastAPI GET 필요
    //
    // GET /profile/{user_id}
    //
    // 응답 예)
    // {
    //   "name": "한은진",
    //   "email": "abc@gmail.com",
    //   "birth": "2004-06-24",
    //   "photo_url": "...",
    // }
    //
    // Flutter 예)
    // final res = await http.get(Uri.parse('$BASE/profile/$userId'));
    // final data = json.decode(res.body);
    // setState(() {
    //   nameCtrl.text = data["name"];
    //   emailCtrl.text = data["email"];
    //   birthCtrl.text = data["birth"];
    //   photoUrl = data["photo_url"];
    // });
    //
    // =========================================================================
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final a = ModalRoute.of(context)?.settings.arguments as Map?;
      if (a != null) {
        setState(() {
          nameCtrl.text = a['name']?.toString() ?? nameCtrl.text;
          userId = a['userId']?.toString() ?? userId;
          final p = a['photoUrl']?.toString();
          if (p != null) {
            photoUrl = p;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    nameCtrl.dispose();
    birthCtrl.dispose();
    pwCtrl.dispose();
    pw2Ctrl.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 🟦 [중요] 프로필 업데이트 — FastAPI POST 또는 PUT 필요
  //
  // POST /profile/update
  //
  // body 예)
  // {
  //   "user_id": "25030024",
  //   "email": "...",
  //   "name": "...",
  //   "birth": "...",
  //   "password": "1234",
  // }
  //
  // Flutter 예)
  // final res = await http.post(
  //   Uri.parse('$BASE/profile/update'),
  //   headers: {"Content-Type": "application/json"},
  //   body: json.encode({
  //     "user_id": userId,
  //     "email": emailCtrl.text,
  //     "name": nameCtrl.text,
  //     "birth": birthCtrl.text,
  //     "password": pwCtrl.text,
  //   }),
  // );
  //
  // 성공하면:
  // Navigator.pop(context);  // 프로필 화면으로 복귀
  // ===========================================================================
  Future<void> _updateProfile() async {
    // ============================================================
    // 🟦 BACKEND TODO (프로필 정보 최종 저장)
    //
    // [요청]
    // PUT /profile/update
    //
    // body (JSON):
    // {
    //   "user_id": "25030024",
    //   "email": emailCtrl.text,
    //   "name": nameCtrl.text,
    //   "birth": birthCtrl.text,
    //   "password": pwCtrl.text,
    //   "photo_url": photoUrl   // 🔥 업로드된 이미지 URL
    // }
    //
    // [설명]
    // - photoUrl은 위에서 이미지 업로드 성공 후 받은 URL
    // - DB user 테이블의 photo_url 컬럼에 저장
    //
    // [성공 시]
    // - 200 OK 반환
    // - ProfileScreen에서 다시 GET 시 변경된 이미지 표시
    // ============================================================
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('프로필이 업데이트되었습니다.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FD),
      body: SafeArea(
        child: Column(
          children: [
            // 🔵 상단 헤더
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF7DB2FF),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text('프로필 수정',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Opacity(
                    opacity: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
            ),

            // 내용
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    // 프로필 사진
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _pickImage, // ⭐ 갤러리 열기
                          child: CircleAvatar(
                            // ============================================================
// 🟦 UI NOTE
// - _pickedImage != null : 갤러리에서 방금 선택한 로컬 이미지 (임시 미리보기)
// - photoUrl            : 서버(S3)에 업로드된 이미지 URL
//
// 👉 업로드 성공 후에는 _pickedImage는 굳이 유지 안 해도 됨
// 👉 photoUrl만으로 NetworkImage 사용 가능
// ============================================================

                            radius: 48,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : NetworkImage(photoUrl) as ImageProvider,
                            child: _pickedImage == null && photoUrl.isEmpty
                                ? const Icon(Icons.camera_alt,
                                    color: Colors.grey)
                                : null,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 4, bottom: 4),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF7DB2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 18, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Text(nameCtrl.text,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: userId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ID가 복사되었습니다')),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ID: $userId',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy,
                              size: 16, color: Colors.black38),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _field(
                      label: '아이디',
                      child: TextField(
                        controller: emailCtrl,
                        decoration: _decoration('example@example.com'),
                      ),
                    ),
                    _field(
                      label: '이름',
                      child: TextField(
                        controller: nameCtrl,
                        decoration: _decoration('홍길동'),
                      ),
                    ),
                    _field(
                      label: '생일',
                      child: TextField(
                        controller: birthCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000, 1, 1),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (picked != null) {
                            birthCtrl.text =
                                '${picked.day.toString().padLeft(2, '0')} / '
                                '${picked.month.toString().padLeft(2, '0')} / '
                                '${picked.year}';
                          }
                        },
                        decoration: _decoration('DD / MM / YYYY'),
                      ),
                    ),

                    _field(
                      label: '비밀번호',
                      child: TextField(
                        controller: pwCtrl,
                        obscureText: hidePw,
                        decoration: _decoration(null).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(hidePw
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() => hidePw = !hidePw),
                          ),
                        ),
                      ),
                    ),
                    _field(
                      label: '비밀번호 확인',
                      child: TextField(
                        controller: pw2Ctrl,
                        obscureText: hidePw2,
                        decoration: _decoration(null).copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(hidePw2
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() => hidePw2 = !hidePw2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 업데이트 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!_validatePassword()) return;
                          _updateProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7DB2FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('프로필 업데이트'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _decoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFD6E6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  bool _validatePassword() {
    if (pwCtrl.text.isEmpty && pw2Ctrl.text.isEmpty) return true;

    if (pwCtrl.text != pw2Ctrl.text) {
      _showError('비밀번호가 일치하지 않습니다');
      return false;
    }

    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$');
    if (!regex.hasMatch(pwCtrl.text)) {
      _showError('비밀번호는 8자 이상이며 대문자와 숫자를 포함해야 합니다');
      return false;
    }

    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// 화면 시연용 분석 기록 목업.
///
/// API 키 없이도 홈의 최근 분석, 기록 탭, 분석 결과 화면을 볼 수 있게 앱을
/// 처음 실행할 때 한 번만 기록에 넣는다([HistoryService.seedDemoIfNeeded]).
/// 사진은 assets/demo/ 에 넣어 둔 실제 현장 장비 사진이고, 'asset' 키로 넘기면
/// 기록을 넣을 때 기록 사진 폴더로 복사된다.
///
/// 문구는 ko/en/vi/km/ne/th 6개 언어를 모두 담는다.
/// (km·ne·th 는 기계 번역이며 현지 검수 전이다.)
///
/// 시각은 넣는 순간을 기준으로 "오늘 / 어제 / 3일 전"에 흩어지게 만든다.
List<Map<String, dynamic>> demoHistoryEntries(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final threeDaysAgo = today.subtract(const Duration(days: 3));

  Map<String, dynamic> entry(
    String id,
    String asset,
    DateTime time,
    Map<String, dynamic> result,
  ) => {
    'id': 'demo-$id',
    'result': result,
    'asset': 'assets/demo/$asset',
    'imagePath': '',
    'timestamp': time.toIso8601String(),
  };

  return [
    // ── 테이블쏘 (오늘, 25분 전) ──────────────────────────────────────────────
    entry(
      'table-saw',
      'table_saw.jpg',
      now.subtract(const Duration(minutes: 25)),
      {
        'name': {
          'ko': '테이블쏘',
          'en': 'Table Saw',
          'vi': 'Máy cưa bàn',
          'km': 'ម៉ាស៊ីនរណារតុ',
          'ne': 'टेबल स',
          'th': 'เลื่อยวงเดือนแบบตั้งโต๊ะ',
        },
        'category': {
          'ko': '목공 절단 기계 / 테이블형 원형톱',
          'en': 'Woodworking cutting machine / table-mounted circular saw',
          'vi': 'Máy cắt gỗ / cưa đĩa gắn bàn',
          'km': 'ម៉ាស៊ីនកាត់ឈើ / រណារមូលបញ្ចូលតុ',
          'ne': 'काठ काट्ने मेसिन / टेबलमा जडित गोलाकार स',
          'th': 'เครื่องตัดไม้ / เลื่อยวงเดือนติดตั้งบนโต๊ะ',
        },
        'usage': {
          'ko': '테이블 위로 올라온 원형 톱날에 목재를 밀어 넣어 직선으로 켜는 재단 공정에 쓴다.',
          'en':
              'Used to rip timber in straight lines by feeding it into a circular blade rising through the table.',
          'vi':
              'Dùng để xẻ gỗ theo đường thẳng bằng cách đẩy gỗ vào lưỡi cưa đĩa nhô lên khỏi mặt bàn.',
          'km':
              'ប្រើសម្រាប់កាត់ឈើជាបន្ទាត់ត្រង់ ដោយរុញឈើចូលទៅក្នុងផ្លែរណារមូលដែលលេចឡើងពីលើតុ។',
          'ne': 'टेबलबाट माथि निस्केको गोलाकार ब्लेडमा काठ धकेलेर सीधा रेखामा चिर्न प्रयोग गरिन्छ।',
          'th': 'ใช้ผลักไม้เข้าหาใบเลื่อยวงเดือนที่โผล่ขึ้นมาเหนือโต๊ะเพื่อผ่าไม้เป็นเส้นตรง',
        },
        'hazards': {
          'ko': [
            '킥백 — 절단 중 소재가 톱날 뒷날에 물려 작업자 쪽으로 튄다',
            '회전하는 톱날에 손가락이 닿으면 절단된다',
            '목분진이 공기 중에 쌓여 호흡기 질환과 분진 화재를 일으킨다',
          ],
          'en': [
            'Kickback — the workpiece catches the rear of the blade and is thrown back at the operator',
            'Fingers contacting the spinning blade are severed',
            'Airborne wood dust causes respiratory disease and dust fires',
          ],
          'vi': [
            'Giật ngược — phôi bị kẹt vào phía sau lưỡi cưa và văng về phía người thao tác',
            'Ngón tay chạm vào lưỡi cưa đang quay sẽ bị cắt đứt',
            'Bụi gỗ trong không khí gây bệnh hô hấp và cháy bụi',
          ],
          'km': [
            'ការខ្ទាត់ត្រឡប់ — ឈើជាប់នឹងផ្នែកខាងក្រោយផ្លែរណារ ហើយខ្ទាត់មករកអ្នកធ្វើការ',
            'ម្រាមដៃប៉ះផ្លែរណារដែលកំពុងវិល នឹងត្រូវកាត់ដាច់',
            'ធូលីឈើក្នុងខ្យល់បង្កជំងឺផ្លូវដង្ហើម និងអគ្គិភ័យធូលី',
          ],
          'ne': [
            'किकब्याक — काट्दा सामग्री ब्लेडको पछाडिको भागमा अल्झेर कामदारतिर उछिट्टिन्छ',
            'घुम्दै गरेको ब्लेडमा औंला छोइएमा काटिन्छ',
            'हावामा उड्ने काठको धुलोले श्वासप्रश्वास रोग र धुलो आगलागी निम्त्याउँछ',
          ],
          'th': [
            'คิกแบ็ก — ชิ้นงานติดด้านหลังใบเลื่อยแล้วดีดกลับมาที่ผู้ปฏิบัติงาน',
            'นิ้วที่สัมผัสใบเลื่อยที่หมุนอยู่จะถูกตัดขาด',
            'ฝุ่นไม้ในอากาศทำให้เกิดโรคระบบหายใจและไฟไหม้จากฝุ่น',
          ],
        },
        'required_ppe': {
          'ko': ['보안경', '방진마스크', '귀마개'],
          'en': ['Safety glasses', 'Dust mask', 'Hearing protection'],
          'vi': ['Kính bảo hộ', 'Khẩu trang chống bụi', 'Nút bịt tai'],
          'km': ['វ៉ែនតាសុវត្ថិភាព', 'ម៉ាស់ការពារធូលី', 'ឧបករណ៍ការពារត្រចៀក'],
          'ne': ['सुरक्षा चश्मा', 'धुलो मास्क', 'कान सुरक्षा'],
          'th': ['แว่นตานิรภัย', 'หน้ากากกันฝุ่น', 'ที่อุดหู'],
        },
        'prohibited': {
          'ko': [
            '분할날과 톱날 덮개를 떼고 작업하지 말 것 — 킥백을 막는 장치다',
            '좁은 소재를 맨손으로 밀지 말 것 — 푸시스틱을 쓴다',
            '장갑을 끼고 작업하지 말 것 — 톱날에 말려 들어간다',
          ],
          'en': [
            'Do not remove the riving knife or blade guard — they prevent kickback',
            'Do not push narrow stock by hand — use a push stick',
            'Do not wear gloves — they get pulled into the blade',
          ],
          'vi': [
            'Không tháo dao tách và nắp che lưỡi cưa — chúng ngăn giật ngược',
            'Không dùng tay đẩy phôi hẹp — hãy dùng thanh đẩy',
            'Không đeo găng tay — găng dễ bị cuốn vào lưỡi cưa',
          ],
          'km': [
            'កុំដករបាំងផ្លែរណារ និងកាំបិតបំបែកចេញ — ពួកវាការពារការខ្ទាត់ត្រឡប់',
            'កុំរុញឈើតូចចង្អៀតដោយដៃទទេ — ត្រូវប្រើដំបងរុញ',
            'កុំពាក់ស្រោមដៃ — វាអាចត្រូវបានទាញចូលទៅក្នុងផ្លែរណារ',
          ],
          'ne': [
            'राइभिङ नाइफ र ब्लेड गार्ड नहटाउनुहोस् — तिनले किकब्याक रोक्छन्',
            'साँघुरो सामग्री हातले नधकेल्नुहोस् — पुश स्टिक प्रयोग गर्नुहोस्',
            'पन्जा नलगाउनुहोस् — ब्लेडले तानेर लैजान सक्छ',
          ],
          'th': [
            'ห้ามถอดมีดแยกและฝาครอบใบเลื่อย — อุปกรณ์เหล่านี้ป้องกันคิกแบ็ก',
            'ห้ามใช้มือดันชิ้นงานแคบ — ให้ใช้ไม้ดัน',
            'ห้ามสวมถุงมือ — อาจถูกใบเลื่อยดึงเข้าไป',
          ],
        },
      },
    ),

    // ── 아크용접기 (오늘, 3시간 전) ───────────────────────────────────────────
    entry(
      'arc-welder',
      'arc_welder.jpg',
      now.subtract(const Duration(hours: 3)),
      {
        'name': {
          'ko': '인버터 아크 용접기',
          'en': 'Inverter Arc Welder',
          'vi': 'Máy hàn hồ quang biến tần',
          'km': 'ម៉ាស៊ីនផ្សារអ័ក inverter',
          'ne': 'इन्भर्टर आर्क वेल्डिङ मेसिन',
          'th': 'เครื่องเชื่อมอาร์กแบบอินเวอร์เตอร์',
        },
        'category': {
          'ko': '금속 접합 장비 / 피복아크 용접기',
          'en': 'Metal joining equipment / shielded metal arc welder',
          'vi': 'Thiết bị hàn kim loại / máy hàn hồ quang que bọc',
          'km': 'ឧបករណ៍ភ្ជាប់លោហៈ / ម៉ាស៊ីនផ្សារអ័កដោយដែកផ្សារស្រោប',
          'ne': 'धातु जोड्ने उपकरण / आवरणयुक्त आर्क वेल्डिङ मेसिन',
          'th': 'อุปกรณ์เชื่อมโลหะ / เครื่องเชื่อมอาร์กลวดหุ้มฟลักซ์',
        },
        'usage': {
          'ko': '피복 용접봉에 전류를 흘려 아크를 일으키고, 그 열로 금속을 녹여 붙이는 접합 작업에 쓴다.',
          'en':
              'Used to join metal by striking an arc through a coated electrode and melting the base metal.',
          'vi':
              'Dùng để nối kim loại bằng cách tạo hồ quang qua que hàn bọc và làm nóng chảy kim loại nền.',
          'km':
              'ប្រើសម្រាប់ភ្ជាប់លោហៈ ដោយបញ្ចេញអ័កតាមដែកផ្សារស្រោប ហើយរលាយលោហៈមូលដ្ឋាន។',
          'ne': 'आवरणयुक्त इलेक्ट्रोडबाट आर्क निकालेर आधार धातु पगालेर जोड्न प्रयोग गरिन्छ।',
          'th': 'ใช้เชื่อมโลหะโดยจุดอาร์กผ่านลวดเชื่อมหุ้มฟลักซ์และหลอมโลหะฐาน',
        },
        'hazards': {
          'ko': [
            '아크 광선의 강한 자외선에 노출되면 각막에 화상을 입는 전광성 안염이 생긴다',
            '용접 흄과 유해가스를 들이마시면 호흡기와 신경계가 손상된다',
            '1000도가 넘는 스패터가 튀어 피부 화상과 주변 가연물 화재를 일으킨다',
          ],
          'en': [
            'Intense UV from the arc burns the cornea, causing arc eye (photokeratitis)',
            'Inhaled welding fume and gases damage the lungs and nervous system',
            'Spatter above 1000°C burns skin and ignites nearby combustibles',
          ],
          'vi': [
            'Tia UV mạnh từ hồ quang gây bỏng giác mạc (viêm giác mạc do hồ quang)',
            'Hít khói hàn và khí độc gây tổn thương phổi và hệ thần kinh',
            'Xỉ hàn trên 1000°C bắn ra gây bỏng da và bắt lửa vật dễ cháy',
          ],
          'km': [
            'កាំរស្មី UV ខ្លាំងពីអ័កបង្កការរលាកកែវភ្នែក (រោគភ្នែកពីអ័ក)',
            'ស្រូបផ្សែងផ្សារ និងឧស្ម័នពុល បង្កគ្រោះថ្នាក់ដល់សួត និងប្រព័ន្ធប្រសាទ',
            'ស្បាតក្តៅលើស ១០០០ អង្សា បង្កការរលាកស្បែក និងឆាបឆេះវត្ថុងាយឆេះនៅជុំវិញ',
          ],
          'ne': [
            'आर्कबाट आउने तीव्र UV ले कर्नियामा जलन गराई आर्क आई हुन्छ',
            'वेल्डिङ धुवाँ र ग्यास सासमा लिँदा फोक्सो र स्नायु प्रणाली बिग्रन्छ',
            '१००० डिग्रीभन्दा तातो स्प्याटरले छाला पोल्छ र नजिकको ज्वलनशील वस्तु सल्काउँछ',
          ],
          'th': [
            'รังสียูวีเข้มจากอาร์กทำให้กระจกตาไหม้ เกิดโรคตาจากแสงเชื่อม',
            'การสูดควันเชื่อมและแก๊สพิษทำลายปอดและระบบประสาท',
            'สะเก็ดร้อนกว่า 1000 องศาทำให้ผิวไหม้และจุดไฟวัสดุติดไฟใกล้เคียง',
          ],
        },
        'required_ppe': {
          'ko': ['차광번호 10 이상 용접면', '가죽 용접장갑과 방염 앞치마', '용접 흄용 방진마스크'],
          'en': [
            'Welding helmet, shade 10 or darker',
            'Leather welding gloves and flame-resistant apron',
            'Fume-rated respirator',
          ],
          'vi': [
            'Mặt nạ hàn độ tối từ số 10 trở lên',
            'Găng tay hàn da và tạp dề chống cháy',
            'Khẩu trang lọc khói hàn',
          ],
          'km': [
            'មុខការពារផ្សារ លេខងងឹត ១០ ឬលើសនេះ',
            'ស្រោមដៃស្បែកសម្រាប់ផ្សារ និងអាវការពារភ្លើង',
            'ម៉ាស់ការពារផ្សែងផ្សារ',
          ],
          'ne': [
            'शेड नम्बर १० वा सोभन्दा गाढा वेल्डिङ हेलमेट',
            'छालाको वेल्डिङ पन्जा र आगो प्रतिरोधी एप्रोन',
            'वेल्डिङ धुवाँ छान्ने मास्क',
          ],
          'th': [
            'หน้ากากเชื่อมเบอร์ 10 ขึ้นไป',
            'ถุงมือหนังสำหรับงานเชื่อมและผ้ากันเปื้อนกันไฟ',
            'หน้ากากกรองควันเชื่อม',
          ],
        },
        'prohibited': {
          'ko': [
            '용접면 없이 아크를 직접 보지 말 것 — 몇 초 노출로도 전광성 안염이 생긴다',
            '환기 없는 밀폐 공간에서 작업하지 말 것 — 흄이 그대로 쌓인다',
            '젖은 장갑이나 젖은 바닥에서 작업하지 말 것 — 감전 위험이 크게 올라간다',
          ],
          'en': [
            'Never look at the arc without a helmet — a few seconds causes arc eye',
            'Do not weld in an enclosed space without ventilation — fume accumulates',
            'Do not work with wet gloves or on a wet floor — shock risk rises sharply',
          ],
          'vi': [
            'Không nhìn hồ quang khi không đeo mặt nạ — vài giây cũng gây viêm giác mạc',
            'Không hàn trong không gian kín thiếu thông gió — khói sẽ tích tụ',
            'Không làm việc với găng ướt hoặc trên sàn ướt — nguy cơ điện giật tăng mạnh',
          ],
          'km': [
            'កុំមើលអ័កដោយគ្មានមុខការពារ — ប៉ុន្មានវិនាទីក៏បង្កជំងឺភ្នែកដែរ',
            'កុំផ្សារក្នុងកន្លែងបិទជិតដែលគ្មានខ្យល់ចេញចូល — ផ្សែងនឹងកកកុញ',
            'កុំធ្វើការដោយស្រោមដៃសើម ឬលើឥដ្ឋសើម — គ្រោះថ្នាក់ឆក់កើនឡើងខ្លាំង',
          ],
          'ne': [
            'हेलमेटविना आर्क नहेर्नुहोस् — केही सेकेन्डले पनि आर्क आई हुन्छ',
            'हावा नचल्ने बन्द ठाउँमा वेल्डिङ नगर्नुहोस् — धुवाँ जम्मा हुन्छ',
            'भिजेको पन्जा वा भिजेको भुइँमा काम नगर्नुहोस् — करेन्ट लाग्ने जोखिम धेरै बढ्छ',
          ],
          'th': [
            'ห้ามมองอาร์กโดยไม่สวมหน้ากาก — เพียงไม่กี่วินาทีก็ทำให้ตาอักเสบ',
            'ห้ามเชื่อมในที่อับอากาศที่ไม่มีการระบาย — ควันจะสะสม',
            'ห้ามทำงานด้วยถุงมือเปียกหรือบนพื้นเปียก — ความเสี่ยงไฟดูดเพิ่มขึ้นมาก',
          ],
        },
      },
    ),

    // ── 유압프레스 (어제) ────────────────────────────────────────────────────
    entry(
      'hydraulic-press',
      'hydraulic_press.jpg',
      yesterday.add(const Duration(hours: 14, minutes: 10)),
      {
        'name': {
          'ko': '4주식 유압 프레스',
          'en': 'Four-Column Hydraulic Press',
          'vi': 'Máy ép thủy lực bốn trụ',
          'km': 'ម៉ាស៊ីនសង្កត់ធារាសាស្ត្របួនសសរ',
          'ne': 'चार खम्बे हाइड्रोलिक प्रेस',
          'th': 'เครื่องอัดไฮดรอลิกสี่เสา',
        },
        'category': {
          'ko': '금속 성형 가공 기계 / 유압 구동 프레스',
          'en': 'Metal forming machine / hydraulically driven press',
          'vi': 'Máy tạo hình kim loại / máy ép dẫn động thủy lực',
          'km': 'ម៉ាស៊ីនបង្កើតរូបរាងលោហៈ / ម៉ាស៊ីនសង្កត់ដោយធារាសាស្ត្រ',
          'ne': 'धातु आकार दिने मेसिन / हाइड्रोलिक चालित प्रेस',
          'th': 'เครื่องขึ้นรูปโลหะ / เครื่องอัดขับด้วยไฮดรอลิก',
        },
        'usage': {
          'ko': '유압 실린더로 상형을 눌러 금속 판재를 성형하거나 타발하는 공정에 쓴다.',
          'en':
              'Used to form or blank sheet metal by driving the upper die down with a hydraulic cylinder.',
          'vi':
              'Dùng để tạo hình hoặc dập tấm kim loại bằng cách hạ khuôn trên nhờ xi lanh thủy lực.',
          'km':
              'ប្រើសម្រាប់បង្កើតរូបរាង ឬកាត់សន្លឹកលោហៈ ដោយសង្កត់ពុម្ពខាងលើចុះដោយស៊ីឡាំងធារាសាស្ត្រ។',
          'ne':
              'हाइड्रोलिक सिलिन्डरले माथिल्लो डाइ तल धकेलेर धातुको पाता आकार दिन वा काट्न प्रयोग गरिन्छ।',
          'th': 'ใช้ขึ้นรูปหรือปั๊มตัดแผ่นโลหะโดยกดแม่พิมพ์บนลงมาด้วยกระบอกไฮดรอลิก',
        },
        'hazards': {
          'ko': [
            '상형과 하형 사이에 손이 들어가면 절단되거나 압착된다',
            '고압 유압 호스가 터지면 기름이 분사되어 피부를 뚫고 들어간다',
            '성형 중 소재나 파편이 튀어나와 얼굴을 친다',
          ],
          'en': [
            'Hands between the upper and lower die are crushed or severed',
            'A burst high-pressure hose injects oil through the skin',
            'Workpieces or fragments fly out during forming and strike the face',
          ],
          'vi': [
            'Tay đưa vào giữa khuôn trên và khuôn dưới sẽ bị nghiền hoặc cắt đứt',
            'Ống thủy lực áp cao vỡ có thể phun dầu xuyên qua da',
            'Phôi hoặc mảnh vỡ văng ra khi tạo hình và đập vào mặt',
          ],
          'km': [
            'ដៃដែលនៅចន្លោះពុម្ពខាងលើ និងខាងក្រោម នឹងត្រូវកិន ឬកាត់ដាច់',
            'បំពង់ធារាសាស្ត្រសម្ពាធខ្ពស់បែក អាចបាញ់ប្រេងចូលក្នុងស្បែក',
            'ឈើការងារ ឬបំណែកអាចខ្ទាត់ចេញមកបុកមុខពេលបង្កើតរូបរាង',
          ],
          'ne': [
            'माथिल्लो र तल्लो डाइबीच परेको हात पिसिन्छ वा काटिन्छ',
            'उच्च चापको हाइड्रोलिक होज फुट्दा तेल छालाभित्र पस्न सक्छ',
            'आकार दिने क्रममा सामग्री वा टुक्रा उछिट्टिएर अनुहारमा लाग्छ',
          ],
          'th': [
            'มือที่อยู่ระหว่างแม่พิมพ์บนและล่างจะถูกบดหรือตัดขาด',
            'ท่อไฮดรอลิกแรงดันสูงแตกอาจพ่นน้ำมันทะลุผิวหนัง',
            'ชิ้นงานหรือเศษวัสดุกระเด็นออกมาโดนใบหน้าขณะขึ้นรูป',
          ],
        },
        'required_ppe': {
          'ko': ['보안경', '안전화', '안전모'],
          'en': ['Safety glasses', 'Safety shoes', 'Hard hat'],
          'vi': ['Kính bảo hộ', 'Giày bảo hộ', 'Mũ bảo hộ'],
          'km': ['វ៉ែនតាសុវត្ថិភាព', 'ស្បែកជើងសុវត្ថិភាព', 'មួកសុវត្ថិភាព'],
          'ne': ['सुरक्षा चश्मा', 'सुरक्षा जुत्ता', 'सुरक्षा हेलमेट'],
          'th': ['แว่นตานิรภัย', 'รองเท้านิรภัย', 'หมวกนิรภัย'],
        },
        'prohibited': {
          'ko': [
            '금형 사이에 손이나 공구를 넣지 말 것',
            '양수조작 버튼을 한 손으로 누르도록 고정하거나 개조하지 말 것',
            '방호장치와 안전블록을 해제한 상태로 운전하지 말 것',
          ],
          'en': [
            'Never put hands or tools between the dies',
            'Do not tape down or modify the two-hand controls',
            'Do not run the press with guards or the safety block removed',
          ],
          'vi': [
            'Không đưa tay hoặc dụng cụ vào giữa hai khuôn',
            'Không cố định hay chỉnh sửa nút điều khiển hai tay',
            'Không vận hành khi đã tháo bộ bảo vệ hoặc khối an toàn',
          ],
          'km': [
            'កុំដាក់ដៃ ឬឧបករណ៍ចូលចន្លោះពុម្ព',
            'កុំចងភ្ជាប់ ឬកែប្រែប៊ូតុងបញ្ជាដោយដៃទាំងពីរ',
            'កុំដំណើរការនៅពេលដករបាំងការពារ ឬប្លុកសុវត្ថិភាពចេញ',
          ],
          'ne': [
            'डाइहरूबीच हात वा औजार नराख्नुहोस्',
            'दुई हातले चलाउने बटन टेप गरेर वा परिमार्जन नगर्नुहोस्',
            'गार्ड वा सुरक्षा ब्लक हटाएर मेसिन नचलाउनुहोस्',
          ],
          'th': [
            'ห้ามสอดมือหรือเครื่องมือเข้าระหว่างแม่พิมพ์',
            'ห้ามมัดหรือดัดแปลงปุ่มควบคุมสองมือ',
            'ห้ามเดินเครื่องขณะถอดการ์ดหรือบล็อกนิรภัยออก',
          ],
        },
      },
    ),

    // ── 지게차 (어제) ────────────────────────────────────────────────────────
    entry(
      'forklift',
      'forklift.jpg',
      yesterday.add(const Duration(hours: 9, minutes: 40)),
      {
        'name': {
          'ko': '카운터밸런스 지게차',
          'en': 'Counterbalance Forklift',
          'vi': 'Xe nâng đối trọng',
          'km': 'ឡានស្ទូចប្រភេទថ្លឹងទម្ងន់',
          'ne': 'काउन्टरब्यालेन्स फोर्कलिफ्ट',
          'th': 'รถโฟล์คลิฟท์แบบถ่วงน้ำหนัก',
        },
        'category': {
          'ko': '물류 운반 장비 / 좌승식 지게차',
          'en': 'Material handling equipment / sit-down counterbalance truck',
          'vi': 'Thiết bị vận chuyển hàng / xe nâng ngồi lái',
          'km': 'ឧបករណ៍ដឹកជញ្ជូនទំនិញ / ឡានស្ទូចប្រភេទអង្គុយបើក',
          'ne': 'सामान ओसार्ने उपकरण / बसेर चलाउने काउन्टरब्यालेन्स ट्रक',
          'th': 'อุปกรณ์ขนถ่ายวัสดุ / รถยกแบบนั่งขับถ่วงน้ำหนัก',
        },
        'usage': {
          'ko': '팔레트에 실린 화물을 포크로 들어 올려 창고와 하역장 사이를 운반하는 데 쓴다.',
          'en':
              'Used to lift palletised loads on its forks and move them between the warehouse and loading dock.',
          'vi':
              'Dùng để nâng hàng trên pallet bằng càng và di chuyển giữa kho và bến bốc dỡ.',
          'km':
              'ប្រើសម្រាប់លើកទំនិញនៅលើផាលែត ហើយដឹកវាចន្លោះឃ្លាំង និងកន្លែងផ្ទុកទំនិញ។',
          'ne': 'प्यालेटमा राखिएको सामान काँटाले उठाएर गोदाम र लोडिङ डकबीच ओसार्न प्रयोग गरिन्छ।',
          'th': 'ใช้ยกสินค้าบนพาเลทด้วยงาและเคลื่อนย้ายระหว่างคลังสินค้ากับท่าขนถ่าย',
        },
        'hazards': {
          'ko': [
            '후진할 때 사각지대에 있는 보행자와 충돌한다',
            '급선회하거나 과적하면 차체가 옆으로 넘어진다',
            '들어 올린 화물이 떨어져 아래에 있는 사람을 덮친다',
          ],
          'en': [
            'Pedestrians in the blind spot are struck while reversing',
            'Sharp turns or overloading tip the truck sideways',
            'Raised loads fall onto anyone standing underneath',
          ],
          'vi': [
            'Người đi bộ trong điểm mù bị đâm khi xe lùi',
            'Quay gấp hoặc chở quá tải làm xe lật nghiêng',
            'Hàng đang nâng rơi xuống người đứng bên dưới',
          ],
          'km': [
            'អ្នកថ្មើរជើងនៅក្នុងចំណុចមិនឃើញ ត្រូវបានបុកពេលថយក្រោយ',
            'ការបត់ខ្លាំង ឬផ្ទុកលើសទម្ងន់ ធ្វើឱ្យឡានផ្អៀងក្រឡាប់',
            'ទំនិញដែលលើកខ្ពស់អាចធ្លាក់មកលើមនុស្សនៅខាងក្រោម',
          ],
          'ne': [
            'पछाडि जाँदा ब्लाइन्ड स्पटमा रहेका पैदलयात्रीलाई ठक्कर लाग्छ',
            'तीव्र मोड वा ओभरलोडले गाडी छेउतिर पल्टिन्छ',
            'उठाइएको सामान तल उभिएका मानिसमाथि खस्छ',
          ],
          'th': [
            'คนเดินเท้าในจุดอับสายตาถูกชนขณะรถถอยหลัง',
            'การเลี้ยวกะทันหันหรือบรรทุกเกินทำให้รถพลิกด้านข้าง',
            'สินค้าที่ยกขึ้นอาจตกใส่คนที่อยู่ด้านล่าง',
          ],
        },
        'required_ppe': {
          'ko': ['안전모', '안전화', '형광 안전조끼'],
          'en': ['Hard hat', 'Safety shoes', 'High-visibility vest'],
          'vi': ['Mũ bảo hộ', 'Giày bảo hộ', 'Áo phản quang'],
          'km': ['មួកសុវត្ថិភាព', 'ស្បែកជើងសុវត្ថិភាព', 'អាវកាក់ឆ្លុះពន្លឺ'],
          'ne': ['सुरक्षा हेलमेट', 'सुरक्षा जुत्ता', 'प्रतिबिम्बित भेस्ट'],
          'th': ['หมวกนิรภัย', 'รองเท้านิรภัย', 'เสื้อกั๊กสะท้อนแสง'],
        },
        'prohibited': {
          'ko': [
            '포크에 사람을 태우거나 올라서지 말 것',
            '들어 올린 화물 아래로 지나가거나 서 있지 말 것',
            '표시된 정격 하중을 넘겨 싣지 말 것',
          ],
          'en': [
            'Never ride or stand on the forks',
            'Do not walk or stand under a raised load',
            'Do not exceed the rated capacity shown on the data plate',
          ],
          'vi': [
            'Không chở người hoặc đứng trên càng nâng',
            'Không đi hoặc đứng dưới hàng đang được nâng',
            'Không chở vượt tải trọng định mức ghi trên xe',
          ],
          'km': [
            'កុំជិះ ឬឈរលើកាំស្ទូច',
            'កុំដើរ ឬឈរនៅក្រោមទំនិញដែលកំពុងលើក',
            'កុំផ្ទុកលើសទម្ងន់កំណត់ដែលបានសរសេរលើឡាន',
          ],
          'ne': [
            'काँटामा नचढ्नुहोस् वा नउभिनुहोस्',
            'उठाइएको सामानमुनि नहिँड्नुहोस् वा नउभिनुहोस्',
            'गाडीमा लेखिएको क्षमताभन्दा बढी नबोक्नुहोस्',
          ],
          'th': [
            'ห้ามนั่งหรือยืนบนงาของรถยก',
            'ห้ามเดินหรือยืนใต้สินค้าที่กำลังยก',
            'ห้ามบรรทุกเกินพิกัดที่ระบุบนป้ายรถ',
          ],
        },
      },
    ),

    // ── 각도절단기 (3일 전) ──────────────────────────────────────────────────
    entry(
      'miter-saw',
      'miter_saw.jpg',
      threeDaysAgo.add(const Duration(hours: 16, minutes: 5)),
      {
        'name': {
          'ko': '각도절단기',
          'en': 'Compound Miter Saw',
          'vi': 'Máy cắt góc',
          'km': 'ម៉ាស៊ីនរណារកាត់មុំ',
          'ne': 'कम्पाउन्ड माइटर स',
          'th': 'เลื่อยองศาแบบคอมพาวด์',
        },
        'category': {
          'ko': '목공 절단 기계 / 복합 각도 절단기',
          'en': 'Woodworking cutting machine / compound miter saw',
          'vi': 'Máy cắt gỗ / máy cắt góc đa năng',
          'km': 'ម៉ាស៊ីនកាត់ឈើ / រណារកាត់មុំច្រើនទិស',
          'ne': 'काठ काट्ने मेसिन / कम्पाउन्ड माइटर स',
          'th': 'เครื่องตัดไม้ / เลื่อยองศาแบบคอมพาวด์',
        },
        'usage': {
          'ko': '회전 톱날을 아래로 내려 목재를 정해진 각도로 자르는 마감 절단 작업에 쓴다.',
          'en':
              'Used for finish cuts, lowering a spinning blade to cut timber at a set angle.',
          'vi':
              'Dùng cho các nhát cắt hoàn thiện, hạ lưỡi cưa quay để cắt gỗ theo góc đã đặt.',
          'km':
              'ប្រើសម្រាប់កាត់បញ្ចប់ ដោយទម្លាក់ផ្លែរណារវិលចុះកាត់ឈើតាមមុំដែលបានកំណត់។',
          'ne': 'घुम्दै गरेको ब्लेड तल झारेर काठलाई तोकिएको कोणमा फिनिस कट गर्न प्रयोग गरिन्छ।',
          'th': 'ใช้ตัดงานละเอียดโดยกดใบเลื่อยที่หมุนอยู่ลงตัดไม้ตามองศาที่ตั้งไว้',
        },
        'hazards': {
          'ko': [
            '톱날이 완전히 멈추기 전에 들어 올리면 소재가 튀어나온다',
            '소재를 손으로 잡고 자르면 손이 톱날 쪽으로 딸려 들어간다',
            '전원을 껐어도 톱날이 관성으로 계속 돌아 접촉 시 절단된다',
          ],
          'en': [
            'Raising the head before the blade stops throws the offcut',
            'Holding the workpiece by hand pulls the hand toward the blade',
            'The blade keeps coasting after power-off and still cuts on contact',
          ],
          'vi': [
            'Nâng đầu cắt trước khi lưỡi dừng hẳn sẽ làm phôi văng ra',
            'Giữ phôi bằng tay khiến tay bị kéo về phía lưỡi cưa',
            'Lưỡi vẫn quay theo quán tính sau khi tắt điện và vẫn cắt khi chạm',
          ],
          'km': [
            'លើកក្បាលរណារឡើងមុនពេលផ្លែឈប់ នឹងធ្វើឱ្យបំណែកឈើខ្ទាត់ចេញ',
            'ការកាន់ឈើដោយដៃ ធ្វើឱ្យដៃត្រូវទាញទៅរកផ្លែរណារ',
            'ផ្លែរណារនៅតែវិលបន្តទោះបិទភ្លើងហើយ ហើយនៅតែកាត់ពេលប៉ះ',
          ],
          'ne': [
            'ब्लेड नरोकिँदै हेड उठाउँदा काटिएको टुक्रा उछिट्टिन्छ',
            'सामग्री हातले समात्दा हात ब्लेडतिर तानिन्छ',
            'बिजुली बन्द गरेपछि पनि ब्लेड घुमिरहन्छ र छोएमा काट्छ',
          ],
          'th': [
            'การยกหัวเลื่อยก่อนใบหยุดหมุนทำให้เศษไม้กระเด็น',
            'การจับชิ้นงานด้วยมือทำให้มือถูกดึงเข้าหาใบเลื่อย',
            'ใบเลื่อยยังหมุนต่อหลังปิดเครื่องและยังตัดได้เมื่อสัมผัส',
          ],
        },
        'required_ppe': {
          'ko': ['보안경', '방진마스크', '귀마개'],
          'en': ['Safety glasses', 'Dust mask', 'Hearing protection'],
          'vi': ['Kính bảo hộ', 'Khẩu trang chống bụi', 'Nút bịt tai'],
          'km': ['វ៉ែនតាសុវត្ថិភាព', 'ម៉ាស់ការពារធូលី', 'ឧបករណ៍ការពារត្រចៀក'],
          'ne': ['सुरक्षा चश्मा', 'धुलो मास्क', 'कान सुरक्षा'],
          'th': ['แว่นตานิรภัย', 'หน้ากากกันฝุ่น', 'ที่อุดหู'],
        },
        'prohibited': {
          'ko': [
            '짧은 소재를 손으로 잡고 자르지 말 것 — 클램프로 고정한다',
            '톱날이 멈추기 전에 잘린 조각을 치우지 말 것',
            '톱날 덮개를 열린 채 고정해 두지 말 것',
          ],
          'en': [
            'Do not hand-hold short stock — clamp it down',
            'Do not clear offcuts before the blade has stopped',
            'Do not tie the blade guard open',
          ],
          'vi': [
            'Không dùng tay giữ phôi ngắn — hãy kẹp cố định',
            'Không dọn mảnh cắt trước khi lưỡi dừng hẳn',
            'Không cố định nắp che lưỡi ở vị trí mở',
          ],
          'km': [
            'កុំកាន់ឈើខ្លីដោយដៃ — ត្រូវចាប់ជាប់ដោយឧបករណ៍រឹត',
            'កុំយកបំណែកចេញ មុនពេលផ្លែរណារឈប់ទាំងស្រុង',
            'កុំចងរបាំងផ្លែរណារឱ្យនៅបើក',
          ],
          'ne': [
            'छोटो सामग्री हातले नसमात्नुहोस् — क्ल्याम्पले कस्नुहोस्',
            'ब्लेड पूरै नरोकिँदासम्म काटिएको टुक्रा नहटाउनुहोस्',
            'ब्लेड गार्डलाई खुला अवस्थामा नबाँध्नुहोस्',
          ],
          'th': [
            'ห้ามใช้มือจับชิ้นงานสั้น — ให้ใช้แคลมป์ยึด',
            'ห้ามเก็บเศษไม้ก่อนที่ใบเลื่อยจะหยุดสนิท',
            'ห้ามมัดฝาครอบใบเลื่อยให้เปิดค้าง',
          ],
        },
      },
    ),
  ];
}
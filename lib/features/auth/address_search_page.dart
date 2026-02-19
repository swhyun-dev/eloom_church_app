import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AddressSearchPage extends StatefulWidget {
  const AddressSearchPage({super.key});

  @override
  State<AddressSearchPage> createState() => _AddressSearchPageState();
}

class _AddressSearchPageState extends State<AddressSearchPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'EloomAddress',
        onMessageReceived: (msg) {
          // msg.message: JSON 문자열 { roadAddress: "...", zonecode: "...." }
          try {
            final map = jsonDecode(msg.message) as Map<String, dynamic>;
            final road = (map['roadAddress'] ?? '').toString().trim();
            final zone = (map['zonecode'] ?? '').toString().trim();

            // ✅ 도로명주소 + (우편번호) 형태로 리턴
            final result = zone.isNotEmpty ? '($zone) $road' : road;
            Navigator.pop(context, result);
          } catch (_) {
            // 파싱 실패 시 그냥 닫지 않고 무시
          }
        },
      )
      ..loadHtmlString(_html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주소 검색'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: '닫기',
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

/// ✅ 카카오(다음) 우편번호 서비스 HTML
/// - 외부 JS: https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js
/// - 선택 시 Flutter로 postMessage (EloomAddress 채널)
const String _html = r'''
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>주소 검색</title>
  <style>
    html, body { width:100%; height:100%; margin:0; padding:0; }
    #wrap { width:100%; height:100%; }
  </style>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>
<body>
  <div id="wrap"></div>

  <script>
    function openPostcode() {
      new daum.Postcode({
        oncomplete: function(data) {
          // roadAddress: 도로명 주소, zonecode: 우편번호
          var payload = {
            roadAddress: data.roadAddress || '',
            zonecode: data.zonecode || ''
          };

          // Flutter 채널로 전달
          if (window.EloomAddress && window.EloomAddress.postMessage) {
            window.EloomAddress.postMessage(JSON.stringify(payload));
          }
        },
        width: '100%',
        height: '100%'
      }).embed(document.getElementById('wrap'));
    }
    openPostcode();
  </script>
</body>
</html>
''';

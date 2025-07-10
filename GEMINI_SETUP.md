# 🤖 **SETUP GOOGLE GEMINI AI** (Easy + Free!)

## 🎯 **Tại sao chọn Gemini?**

✅ **Hoàn toàn FREE** - 15 requests/minute, 1,500 requests/day  
✅ **Dễ setup** - Chỉ cần API key, không cần training  
✅ **Thông minh** - Hiểu ngôn ngữ tự nhiên ngay lập tức  
✅ **Đã có sẵn** - Package đã được thêm vào project  

---

## 🚀 **SETUP CHỈ 2 BƯỚC**

### **Bước 1: Lấy FREE API Key**

1. **Mở**: https://makersuite.google.com/app/apikey
2. **Đăng nhập** Google account
3. **Click**: `Create API Key`
4. **Copy** API key (dạng: `AIzaSy...`)

### **Bước 2: Thêm API Key vào code**

**Mở file**: `lib/data/services/gemini_ai_service.dart`

**Thay dòng 12:**
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

**Thành:**
```dart
static const String _apiKey = 'AIzaSy_PASTE_YOUR_KEY_HERE';
```

---

## ✅ **TEST NGAY!**

```bash
flutter run
```

**Try these messages:**
- "Hello" 👋
- "Recommend action movies" 🎬
- "Show me trending films" 🔥
- "Find Tom Hanks movies" 🔍

---

## 🌟 **SO SÁNH vs Wit.ai**

| Feature | **Gemini** | Wit.ai |
|---------|----------|--------|
| **Setup** | ⚡ 2 minutes | 🐌 30+ minutes |
| **Training** | ❌ None needed | ✅ Required |
| **Free Tier** | 🎁 1,500/day | 💰 Limited |
| **Vietnamese** | ✅ Native | ⚠️ Basic |
| **Intelligence** | 🧠 GPT-level | 🤖 Rule-based |

---

## 🎬 **Các tính năng AI Chat:**

✅ **Natural conversations** - Nói chuyện tự nhiên  
✅ **Movie recommendations** - Gợi ý theo sở thích  
✅ **Smart search** - Tìm phim theo diễn viên, thể loại  
✅ **Trending & Popular** - Phim hot nhất  
✅ **Context aware** - Nhớ cuộc trò chuyện  
✅ **Quick actions** - Buttons tiện lợi  

---

## 🔧 **Troubleshooting**

**❌ API Key không work?**
- Check đã enable Gemini API
- Verify key không có space thừa
- Restart app sau khi thay key

**❌ Rate limit?**
- FREE: 15 requests/minute
- Chờ 1 phút rồi thử lại

**❌ Vietnamese không hiểu?**
- Gemini hỗ trợ Vietnamese native
- Try English nếu cần

---

## 🎯 **Ready to go!** 

Your AI chatbot is now **10x smarter** with **zero training required**! 🚀 
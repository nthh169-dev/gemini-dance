// Cấu hình dùng chung. CHỈ đặt publishable (anon) key ở đây – key này được phép công khai.
// Tuyệt đối không đặt mật khẩu database hay service_role key vào file này.
window.GD_CONFIG = {
  SUPABASE_URL: "https://qhkdldltwqnwpmifqdcj.supabase.co",
  SUPABASE_KEY: "sb_publishable_th6ALyrrhz5qWwppeBOlRw_ouLOX2CU",
  ADDRESS: "188/5/1 Nguyễn Suý, Q. Tân Phú, Tp.HCM",
  PHONE: "0900000000",
  EMAIL: "geminidance@example.com.vn",
  SOCIAL: {
    tiktok: "https://www.tiktok.com/@gemini.dance169",
    facebook: "https://www.facebook.com/gemini.dance169",
    youtube: "https://www.youtube.com/@GeminiDance"
  },
  // Các video hiện ở Trang chủ (tối đa 5, mới nhất để đầu). Mỗi video là 1 mã (phần sau "watch?v=" trong link YouTube).
  // Không nhúng playlist "videoseries" vì bị lỗi "This video is unavailable" trên Android.
  YOUTUBE_VIDEOS: ["MbON2SK5HSQ", "NrErUhLVhpY", "HnzBKB_zCFw"],
  MAP_EMBED: "https://maps.google.com/maps?q=188%2F5%2F1%20Nguy%E1%BB%85n%20Su%C3%BD%2C%20T%C3%A2n%20Ph%C3%BA%2C%20H%E1%BB%93%20Ch%C3%AD%20Minh&z=16&output=embed"
};

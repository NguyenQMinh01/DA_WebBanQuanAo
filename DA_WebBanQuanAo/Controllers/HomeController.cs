using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DA_WebBanQuanAo.Models;
namespace DA_WebBanQuanAo.Controllers
{
    public class HomeController : Controller
    {
        //
        // GET: /Home/
        QLShopDataContext db = new QLShopDataContext();
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Rong()
        {
            return View();
        }
        [HttpGet]
        public ActionResult DangKy()
        {
            return View();
        }
        [HttpPost]
        
        public ActionResult DangKy(TAIKHOAN tk,FormCollection f)
        {
            var hoten = f["HotenKH"];
            var tendn = f["TenDN"];
            var matkhau = f["MatKhau"];
            var rematkhau = f["ReMatKhau"];
            var dienthoai = f["DienThoai"];
            var ngaysinh = string.Format("{0:MM/DD/YYYY}", f["NgaySinh"]);
            var email = f["Email"];
            var diachi = f["DiaChi"];

            if (String.IsNullOrEmpty(hoten))
            {
                ViewData["Loi1"] = "Họ Tên không được rỗng";

            }
            if (String.IsNullOrEmpty(tendn))
            {
                ViewData["Loi2"] = "Họ Tên đăng nhập được rỗng";

            }
            if (String.IsNullOrEmpty(matkhau))
            {
                ViewData["Loi3"] = "Vui lòng nhập mật khẩu";

            }
            if (String.IsNullOrEmpty(rematkhau))
            {
                ViewData["Loi4"] = "Vui Lòng nhập mật khẩu";

            }
            if (String.IsNullOrEmpty(dienthoai))
            {
                ViewData["Loi5"] = "Vui Lòng nhập số điện thoai";

            }
            if (!String.IsNullOrEmpty(hoten) && !String.IsNullOrEmpty(tendn) && !String.IsNullOrEmpty(matkhau) && !String.IsNullOrEmpty(rematkhau) && !String.IsNullOrEmpty(dienthoai))
            {
                tk.HoTen = hoten;
                tk.TenTK = tendn;
                tk.Pass = matkhau;
                tk.NgaySinh = DateTime.Parse(ngaysinh);
                tk.DiaChi = diachi;
                tk.Gmail = email;
                tk.MaQuyen = 2;            
                db.TAIKHOANs.InsertOnSubmit(tk);
                db.SubmitChanges();
                return RedirectToAction("DangNhap", "Home");
            }
            return View();
        }
        public ActionResult DangNhap()
        {
            return View();
        }
        [HttpPost]
        public ActionResult DangNhap(FormCollection f)
        {
            //khai báo các biên nhận giá trị  form f
            var tendn = f["TenDN"];
            var matkhau = f["MatKhau"];

            TAIKHOAN tk = db.TAIKHOANs.SingleOrDefault(x => x.TenTK == tendn);

            Session["MaKH"] = tk.TenTK;

            if (String.IsNullOrEmpty(tendn))
            {
                ViewData["Loi1"] = "Tên đăng nhập không bỏ trống";

            }
            if (String.IsNullOrEmpty(matkhau))
            {
                ViewData["Loi2"] = "Tên đăng nhập không bỏ trống";

            }
            if (!String.IsNullOrEmpty(tendn) && !String.IsNullOrEmpty(matkhau))
            {
                TAIKHOAN kh = db.TAIKHOANs.SingleOrDefault(c => c.TenTK == tendn && c.Pass == matkhau);
                {
                    if (kh != null && kh.MaQuyen == 2 && Session["GioHang"]!=null)
                    {
                        //ViewBag.TB="Đăng nhập thành công !!!";
                        Session["taikhoan"] = f;
                        return RedirectToAction("ThanhToan", "GioHang");
                    }
                    else if(kh!=null && kh.MaQuyen == 2 && Session["GioHang"]==null)
                    {
                        Session["taikhoan"] = f;
                        return RedirectToAction("SanPham", "SanPham");
                    }
                    else if (kh != null && kh.MaQuyen == 1)
                    {
                        Session["taikhoan"] = f;
                        return RedirectToAction("Index","QuanLy");
                    }
                    else
                        ViewBag.TB = "Sai tên Dn hoặc sai MK,vui lòng nhập lại";

                }
            }
            return View();

        }
        public ActionResult About()
        {
            return View();
        }
    }
}

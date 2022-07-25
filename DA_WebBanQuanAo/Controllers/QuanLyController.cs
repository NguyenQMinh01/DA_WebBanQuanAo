using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DA_WebBanQuanAo.Models;
namespace DA_WebBanQuanAo.Controllers
{
    public class QuanLyController : Controller
    {
        //
        // GET: /QuanLy/
        QLShopDataContext db = new QLShopDataContext();
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult SanPham()
        {
            var listSP = db.SANPHAMs.OrderBy(s => s.TenSP).ToList();
            return View(listSP);
        }
        public ActionResult XoaSanPham(int MaSP)
        {
            SANPHAM sp = db.SANPHAMs.SingleOrDefault(s => s.MaSP == MaSP);
            db.SANPHAMs.DeleteOnSubmit(sp);
            db.SubmitChanges();
            return RedirectToAction("SanPham","QuanLy");
        }
        public ActionResult CapNhatSanPham(int MaSP,FormCollection f)
        {
            SANPHAM sp = db.SANPHAMs.SingleOrDefault(s => s.MaSP == MaSP);
            sp.SoLuong = int.Parse(f["txtSoLuong"].ToString());
            db.SANPHAMs.DeleteOnSubmit(sp);
            db.SANPHAMs.InsertOnSubmit(sp);
            db.SubmitChanges();
            return RedirectToAction("SanPham", "QuanLy");
        }
        public ActionResult User()
        {
            var listUser = db.TAIKHOANs.OrderBy(s => s.TenTK).Where(s=>s.MaQuyen==2).ToList();
            return View(listUser);
        }
        public ActionResult XoaTaiKhoan(string TenTK)
        {
            TAIKHOAN tk = db.TAIKHOANs.SingleOrDefault(s => s.TenTK == TenTK);
            db.TAIKHOANs.DeleteOnSubmit(tk);
            db.SubmitChanges();
            return RedirectToAction("User", "QuanLy");
        }
        public ActionResult CapNhatTaiKhoan(string TenTK, FormCollection f)
        {
            TAIKHOAN tk = db.TAIKHOANs.SingleOrDefault(s => s.TenTK == TenTK);
            tk.Pass = f["Pass"].ToString();
            db.TAIKHOANs.DeleteOnSubmit(tk);
            db.TAIKHOANs.InsertOnSubmit(tk);
            db.SubmitChanges();
            return RedirectToAction("User", "QuanLy");
        }
        public ActionResult HoaDon()
        {
            var lstHD = db.HOADONs.OrderBy(s => s.NgayDat).ToList();
            return View(lstHD);
        }
   
        public ActionResult CapNhatHoaDon(int MaHD,FormCollection f)
        {
            HOADON hd = db.HOADONs.SingleOrDefault(s => s.MaHD == MaHD);
            hd.ngaygiao = Convert.ToDateTime(f["Ngaygiao"]);
            db.HOADONs.DeleteOnSubmit(hd);
            db.HOADONs.InsertOnSubmit(hd);
            db.SubmitChanges();
            return RedirectToAction("HoaDon","QuanLy");

        }
        public ActionResult CT_HoaDon(int MaHD)
        {
            var ct = db.CT_HOADONs.Where(s => s.MaHD == MaHD).ToList();
            return View(ct);
        }
        public ActionResult ThemSanPham(FormCollection f)
        {
            SANPHAM sp = new SANPHAM();
            sp.TenSP = f["TenSP"];
            sp.Images = f["Hinh"];
            sp.SoLuong = Convert.ToInt32(f["txtSoLuong"]);
            sp.Gia = Convert.ToDecimal(f["Gia"]);
            db.SANPHAMs.InsertOnSubmit(sp);
            db.SubmitChanges();
            return RedirectToAction("SanPham","QuanLy");
        }
    }
}

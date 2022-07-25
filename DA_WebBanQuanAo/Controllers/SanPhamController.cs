using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DA_WebBanQuanAo.Models;
namespace DA_WebBanQuanAo.Controllers
{
    public class SanPhamController : Controller
    {
        //
        // GET: /SanPham/
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
        public ActionResult XemChiTiet(int masp)
        {
            SANPHAM sp = db.SANPHAMs.Single(s => s.MaSP == masp);
            if (sp == null)
            {
                return HttpNotFound();
            }
            return View(sp);
        }
        public ActionResult SanPhamNam()
        {
            var listSpNam = db.SANPHAMs.Where(s => s.MaLoai == "L003" || s.MaLoai=="L004").OrderBy(s => s.Gia);
            return View(listSpNam);
        }
        public ActionResult SanPhamNu()
        {
            var listSpNu = db.SANPHAMs.Where(s => s.MaLoai == "L005" || s.MaLoai == "L006").OrderBy(s => s.Gia);
            return View(listSpNu);
        }
        public ActionResult SanPhamUni()
        {
            var listSpUni = db.SANPHAMs.Where(s => s.MaLoai == "L001" || s.MaLoai == "L002").OrderBy(s => s.Gia);
            return View(listSpUni);
        }
        public ActionResult Search(string txt_Search)
        {
            var timkiemsp = db.SANPHAMs.Where(s => s.TenSP.Contains(txt_Search)).ToList();
            return View(timkiemsp);
        }
    }
}

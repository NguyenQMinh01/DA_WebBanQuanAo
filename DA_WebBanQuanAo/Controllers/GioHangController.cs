using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using DA_WebBanQuanAo.Models;

namespace DA_WebBanQuanAo.Controllers
{
    public class GioHangController : Controller
    {
        //
        // GET: /GioHang/

        public ActionResult Index()
        {
            return View();
        }
        QLShopDataContext db = new QLShopDataContext();

        public List<GioHang> LayGioHang()
        {
            List<GioHang> lstGioHang = Session["GioHang"] as List<GioHang>;
            if (lstGioHang == null)
            {
                //Nếu lstGioHang chưa tồn tại thì khởi tạo
                lstGioHang = new List<GioHang>();
                Session["GioHang"] = lstGioHang;
            }
            return lstGioHang;
        }

        public ActionResult ThemGioHang(int MaSP, string strURL)
        {
            //Lấy ra giỏ hàng
            List<GioHang> lstGioHang = LayGioHang();

            //Kiểm tra sách này có tồn tại trong Session["GioHang"] hay chưa?
            GioHang SanPham = lstGioHang.Find(sp => sp.iMaSP == MaSP);
            if (SanPham == null) //chưa có trong giỏ
            {
                SanPham = new GioHang(MaSP);
                lstGioHang.Add(SanPham);
                return Redirect(strURL);
            }
            else
            {
                SanPham.iSoLuong++;
                return Redirect(strURL);
            }
        }
        //Tổng số lượng
        private int TongSoLuong()
        {
            int dem = 0;
            List<GioHang> lstGioHang = Session["GioHang"] as List<GioHang>;
            if (lstGioHang != null)
            {
                dem = lstGioHang.Sum(sp => sp.iSoLuong);
            }
            return dem;
        }

        //Tổng thành tiền
        private double TongThanhTien()
        {
            double tong = 0;
            List<GioHang> lstGioHang = Session["GioHang"] as List<GioHang>;
            if (lstGioHang != null)
            {
                tong += lstGioHang.Sum(sp => sp.dThanhTien);
            }
            return tong;
        }

        //Xây dựng trang Giỏ Hàng
        public ActionResult GioHang()
        {
            if (Session["GioHang"] == null)
            {
                return RedirectToAction("Rong", "Home");
            }
            List<GioHang> lstGioHang = LayGioHang();

            ViewBag.TongSoLuong = TongSoLuong();
            ViewBag.TongThanhTien = TongThanhTien();

            return View(lstGioHang);
        }

        public ActionResult XoaGioHang(int MaSP)
        {
            //Lấy giỏ hàng
            List<GioHang> lstGioHang = LayGioHang();

            //kiểm tra xem sách cần xóa có trong giỏ?
            GioHang sp = lstGioHang.Single(s => s.iMaSP == MaSP);

            // nếu có thì tiến hành xóa
            if (sp != null)
            {
                lstGioHang.RemoveAll(s => s.iMaSP == MaSP);
                return RedirectToAction("GioHang", "GioHang");
            }

            //nếu rỗng
            if (lstGioHang.Count == 0)
            {
                return RedirectToAction("Rong", "Home");
            }
            return RedirectToAction("GioHang", "GioHang");
        }
        public ActionResult XoaGioHangAll()
        {
            List<GioHang> lstGioHang = LayGioHang();
            lstGioHang.Clear();
            return RedirectToAction("Rong", "Home");
        }
        public ActionResult CapNhatGioHang(int MaSP, FormCollection f)
        {
            //lấy giỏ hàng
            List<GioHang> lstGioHang = LayGioHang();

            //kiểm tra xem sách cần cập nhật có trong giỏ?
            GioHang sp = lstGioHang.Single(s => s.iMaSP == MaSP);

            //nếu có tiến hành cập nhật
            if (sp != null)
            {
                sp.iSoLuong = int.Parse(f["txtSoLuong"].ToString());
            }
            return RedirectToAction("GioHang", "GioHang");
        }
        public ActionResult GioHangPartial()
        {
            ViewBag.TongSoLuong = TongSoLuong();
            ViewBag.TongThanhTien = TongThanhTien();
            return PartialView();
        }
        [HttpGet]
        public ActionResult ThanhToan()
        {
            //kiểm tra đăng nhập
            if (Session["taikhoan"] == null || Session["taikhoan"].ToString() == "")
            {
                return RedirectToAction("DangNhap", "Home");
            }
            else
            {

                var order = new HOADON();
                order.NgayDat = DateTime.Now;                
                order.TenTK = Session["MaKH"].ToString();
                order.TongTien = Convert.ToDecimal(TongThanhTien());
                order.ngaygiao = null;
                //thêm vào chi tiết đơn hàng

                db.HOADONs.InsertOnSubmit(order);
                db.SubmitChanges();

                var cart = (List<GioHang>)Session["GioHang"];
                foreach (var item in cart)
                {
                    var chitiet = new CT_HOADON();

                    chitiet.MaSP = item.iMaSP;
                    chitiet.MaHD = order.MaHD;
                    chitiet.SoLuong = item.iSoLuong;
                    chitiet.ThanhTien = Convert.ToDecimal(item.dDonGia);
                    db.CT_HOADONs.InsertOnSubmit(chitiet);
                    db.SubmitChanges();

                }
                Session["GioHang"] = null;
                ViewBag.tt = "Mua hàng thành công !!!";
                return View();
            }

        }
    }
}

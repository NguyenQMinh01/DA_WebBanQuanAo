using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace DA_WebBanQuanAo.Models
{
    public class GioHang
    {
        QLShopDataContext db = new QLShopDataContext();

        public int iMaSP { get; set; }
        public string sTenSP { get; set; }
        public string sAnhBia { get; set; }
        public double dDonGia { get; set; }
        public int iSoLuong { get; set; }

        public GioHang(int MaSach)
        {
            iMaSP = MaSach;
            SANPHAM sach = db.SANPHAMs.Single(s => s.MaSP == iMaSP);
            sTenSP = sach.TenSP;
            sAnhBia = sach.Images;
            dDonGia = (double)sach.Gia;
            iSoLuong = 1;
        }
        public double dThanhTien
        {
            get { return iSoLuong * dDonGia; }
        }
    }
}
//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Web365Base
{
    using System;
    using System.Collections.Generic;
    
    public partial class tblAdverties_Picture_Map
    {
        public int ID { get; set; }
        public Nullable<int> AdvertiesID { get; set; }
        public Nullable<int> PictureID { get; set; }
        public Nullable<int> DisplayOrder { get; set; }
    
        public virtual tblAdvertise tblAdvertise { get; set; }
        public virtual tblPicture tblPicture { get; set; }
    }
}
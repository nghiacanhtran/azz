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
    
    public partial class webpages_Roles
    {
        public webpages_Roles()
        {
            this.tblPage = new HashSet<tblPage>();
            this.UserProfile = new HashSet<UserProfile>();
        }
    
        public int RoleId { get; set; }
        public string RoleName { get; set; }
        public string Detail { get; set; }
        public Nullable<System.DateTime> DateCreated { get; set; }
        public Nullable<System.DateTime> DateUpdated { get; set; }
        public string CreateBy { get; set; }
        public string UpdateBy { get; set; }
        public Nullable<bool> IsShow { get; set; }
        public Nullable<bool> IsDeleted { get; set; }
    
        public virtual ICollection<tblPage> tblPage { get; set; }
        public virtual ICollection<UserProfile> UserProfile { get; set; }
    }
}

using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using Web365Base;
using Web365Business.Front_End.IRepository;
using Web365Domain;
using Web365Utility;

namespace Web365Business.Front_End.Repository
{
    public class OtherRepositoryFE : BaseFE, IOtherRepositoryFE
    {
        public bool AddContact(tblContact contact)
        {
            try
            {
                web365db.tblContact.Add(contact);
                var result = web365db.SaveChanges();

                return result > 0;
            }
            catch (Exception)
            {
                return false;
            }            
        }        
    }
}

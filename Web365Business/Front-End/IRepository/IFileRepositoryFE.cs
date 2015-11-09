using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Web365Base;
using Web365Domain;
using Web365Models;

namespace Web365Business.Front_End.IRepository
{
    public interface IFileRepositoryFE
    {
        FileModel GetListByType(int id, string ascii, int skip, int top);
    }
}

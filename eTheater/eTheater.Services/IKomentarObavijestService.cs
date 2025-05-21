using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public interface IKomentarObavijestService : ICRUDService<Model.KomentarObavijest, KomentarObavijestSearchObject, KomentarObavijestInsertRequest, KomentarObavijestUpdateRequest>
    {
        Task<PagedResult<KomentarObavijestDto>> GetKomentariObavijestiAsync(KomentarObavijestiSearchObjectVM komentarObavijestiSearchObject);

    }
}

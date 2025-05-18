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
    public interface IRepertoarIzvedbaService: ICRUDService<Model.RepertoarIzvedba, RepertoarIzvedbaSearchObject, RepertoarIzvedbaInsertRequest, RepertoarIzvedbaUpdateRequest>
    {
        Task<List<RepertoarIzvedbaDTO>> GetRepertoarIzvedbeWithDetails(int repertoarId);

    }
}

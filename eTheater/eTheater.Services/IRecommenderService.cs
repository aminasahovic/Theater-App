using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public interface IRecommenderService : ICRUDService<Model.Recommender, RecommenderSearchObject, RecommenderInsert, RecommenderUpdate>
    {
        public List<Model.Predstava> Recommend(int id);
        Task<List<RecommenderView>> TrainModelAsync(CancellationToken cancellationToken = default);
        Task DeleteAllRecommendation(CancellationToken cancellationToken = default);
    }
}

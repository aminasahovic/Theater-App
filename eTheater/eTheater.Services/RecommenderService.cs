using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Model.ViewModels;
using eTheater.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Trainers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public class RecommenderService : BaseCRUDService<Model.Recommender, RecommenderSearchObject, Database.Recommender, RecommenderInsert, RecommenderUpdate>, IRecommenderService
    {
        private readonly ETheaterContext _context;
        private readonly IMapper _mapper;
        static MLContext mlContext = null;
        static object isLocked = new object();
        static ITransformer model = null;
        public RecommenderService(Database.ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public List<Model.Predstava> Recommend(int id)
        {
            lock (isLocked)
            {
                if (mlContext == null)
                {
                    mlContext = new MLContext();

                    var tmpData = _context.KomentarPrestavas.ToList();
                    Console.WriteLine(tmpData.Count);

                    var data = new List<PredstavaPreporuka>();

                    foreach (var x in tmpData)
                    {
                        data.Add(new PredstavaPreporuka()
                        {
                            PredstavaID = (uint)x.PredstavaId,
                            KorisnikID = (uint)x.KorisnikId,
                            Ocjena = (float)x.Ocjena
                        });
                    }

                    var trainData = mlContext.Data.LoadFromEnumerable(data);
                    var rowCount = trainData.GetRowCount();

                    if (rowCount > 0)
                    {
                        Console.WriteLine("Data loaded successfully. Row count: " + rowCount);
                    }
                    else
                    {
                        Console.WriteLine("No data loaded. Row count: " + rowCount);
                    };
                    MatrixFactorizationTrainer.Options options = new MatrixFactorizationTrainer.Options
                    {
                        MatrixColumnIndexColumnName = nameof(PredstavaPreporuka.PredstavaID),
                        MatrixRowIndexColumnName = nameof(PredstavaPreporuka.KorisnikID),
                        LabelColumnName = nameof(PredstavaPreporuka.Ocjena),
                        NumberOfIterations = 20,
                        ApproximationRank = 100
                    };


                    var est = mlContext.Recommendation().Trainers.MatrixFactorization(options);

                    model = est.Fit(trainData);
                }
            }
            var predictionengine = mlContext.Model.CreatePredictionEngine<PredstavaPreporuka, CoPredstava_prediction>(model);

            var ocijenjenePredstave = _context.KomentarPrestavas
                                            .Where(x => x.KorisnikId == id)
                                            .Select(x => x.PredstavaId)
                                            .ToList();

            var predstavaNijeOcijenio = _context.Predstavas
                                        .Where(p => !ocijenjenePredstave.Contains(p.Id) && !p.IsDeleted)
                                        .ToList();

            var predvidjeneOcjene = new List<Tuple<Database.Predstava, float>>();

            foreach (var predstava in predstavaNijeOcijenio)
            {
                var movieratingprediction = predictionengine.Predict(
                    new PredstavaPreporuka()
                    {
                        KorisnikID = (uint)id,
                        PredstavaID = (uint)predstava.Id
                    }
                );


                predvidjeneOcjene.Add(Tuple.Create(predstava, movieratingprediction.Score));
            }


            predvidjeneOcjene = predvidjeneOcjene.OrderByDescending(x => x.Item2).Take(3).ToList();


            var recommendedPredstava = _context.Predstavas
                                        .Where(p => predvidjeneOcjene.Select(r => r.Item1.Id).Contains(p.Id))
                                        .ToList();


            var recommendedPredstavaViewModels = _mapper.Map<List<Model.Predstava>>(recommendedPredstava);



            return recommendedPredstavaViewModels;

        }

        public async Task<List<RecommenderView>> TrainModelAsync(CancellationToken cancellationToken = default)
        {
            var korisnici = await _context.Korisniks.ToListAsync(cancellationToken);

            var brojOcjena = await _context.KomentarPrestavas.CountAsync(cancellationToken);

            if (korisnici.Count() > 4 && brojOcjena > 8)
            {
                List<Database.Recommender> recommendList = new List<Database.Recommender>();

                foreach (var korisnik in korisnici)
                {
                    var recommendedFilms = Recommend(korisnik.Id);

                    var resultRecommend = new Database.Recommender()
                    {
                        KorisnikId = korisnik.Id,
                        CoPredstavaId1 = recommendedFilms[0].Id,
                        CoPredstavaId2 = recommendedFilms[1].Id,
                        CoPredstavaId3 = recommendedFilms[2].Id
                    };
                    recommendList.Add(resultRecommend);
                }

                await CreateNewRecommendation(recommendList, cancellationToken);
                await _context.SaveChangesAsync(cancellationToken);

                return _mapper.Map<List<RecommenderView>>(recommendList);
            }
            else
            {
                throw new Exception("Not enough data to make recommendations.");
            }
        }
        public async Task CreateNewRecommendation(List<Database.Recommender> results, CancellationToken cancellationToken = default)
        {
            var existingRecommendations = await _context.Recommenders.ToListAsync(cancellationToken);
            var filmCount = await _context.Predstavas.CountAsync(cancellationToken);
            var recordCount = existingRecommendations.Count;

            if (recordCount != 0)
            {
                if (recordCount > filmCount)
                {
                    for (int i = 0; i < filmCount; i++)
                    {
                        existingRecommendations[i].KorisnikId = results[i].KorisnikId;
                        existingRecommendations[i].CoPredstavaId1 = results[i].CoPredstavaId1;
                        existingRecommendations[i].CoPredstavaId2 = results[i].CoPredstavaId2;
                        existingRecommendations[i].CoPredstavaId3 = results[i].CoPredstavaId3;
                    }

                    for (int i = filmCount; i < recordCount; i++)
                    {
                        _context.Recommenders.Remove(existingRecommendations[i]);
                    }
                }
                else
                {
                    for (int i = 0; i < recordCount; i++)
                    {
                        existingRecommendations[i].KorisnikId = results[i].KorisnikId;
                        existingRecommendations[i].CoPredstavaId1 = results[i].CoPredstavaId1;
                        existingRecommendations[i].CoPredstavaId2 = results[i].CoPredstavaId2;
                        existingRecommendations[i].CoPredstavaId3 = results[i].CoPredstavaId3;
                    }

                    var numToAdd = results.Count - recordCount;
                    if (numToAdd > 0)
                    {
                        await _context.Recommenders.AddRangeAsync(results.Skip(recordCount).Take(numToAdd), cancellationToken);
                    }
                }
            }
            else
            {
                await _context.Recommenders.AddRangeAsync(results, cancellationToken);
            }

            await _context.SaveChangesAsync(cancellationToken);
        }
        public async Task DeleteAllRecommendation(CancellationToken cancellationToken = default)
        {
            await _context.Recommenders.ExecuteDeleteAsync(cancellationToken);
        }

        public class CoPredstava_prediction
        {
            public float Score { get; set; }
        }
    }
}

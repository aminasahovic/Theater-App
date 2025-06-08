using eTheater.Model;
using eTheater.Model.Requests;
using eTheater.Model.SearchObjects;
using eTheater.Services.Database;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace eTheater.Services
{
    public class KorisnikService : BaseCRUDService<Model.Korisnik, KorisniciSearchObject, Database.Korisnik, KorisnikInsertRequest, KorisnikUpdateRequest>,IKorisnikService
    {
        public KorisnikService(ETheaterContext context, IMapper mapper) : base(context, mapper)
        {
        }
        public override IQueryable<Database.Korisnik> AddFilter(KorisniciSearchObject searchObject, IQueryable<Database.Korisnik> query)
        {
            query = base.AddFilter(searchObject, query);
            if (!string.IsNullOrWhiteSpace(searchObject?.ImeGTE))
            {
                query = query.Where(x => x.Ime.StartsWith(searchObject.ImeGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.PrezimeGTE))
            {
                query = query.Where(x => x.Prezime.StartsWith(searchObject.PrezimeGTE));
            }

            if (!string.IsNullOrWhiteSpace(searchObject?.KorisnickoIme))
            {
                query = query.Where(x => x.Username.StartsWith(searchObject.KorisnickoIme));
            }

            if (searchObject.IsTipKorisnika.HasValue)
            {
                query = query.Where(x=> x.TipKorisnika.Id == searchObject.IsTipKorisnika);
            }
            if (searchObject.IsActive!=null)
            {
                query = query.Where(x => x.IsActive ==searchObject.IsActive);

            }
            query = query.OrderByDescending(x => x.Id);
            return query;
        }


        public override void BeforeInsert(KorisnikInsertRequest request, Database.Korisnik entity)
        {
            if (request.Password != request.PasswordPotvrda)
            {
                throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste");
            }

            entity.Salt = GenerateSalt();
            entity.Hash = GenerateHash(entity.Salt, request.Password);
            base.BeforeInsert(request, entity);
        }

        public static string GenerateSalt()
        {
            var byteArray = RNGCryptoServiceProvider.GetBytes(16);


            return Convert.ToBase64String(byteArray);
        }
        public static string GenerateHash(string salt, string password)
        {
            byte[] src = Convert.FromBase64String(salt);
            byte[] bytes = Encoding.Unicode.GetBytes(password);
            byte[] dst = new byte[src.Length + bytes.Length];

            System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
            System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

            HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
            byte[] inArray = algorithm.ComputeHash(dst);
            return Convert.ToBase64String(inArray);
        }

        public override void BeforeUpdate(KorisnikUpdateRequest request, Database.Korisnik entity)
        {
            base.BeforeUpdate(request, entity);
            if (request.Password != null)
            {
                if (request.Password != request.PasswordPotvrda)
                {
                    throw new Exception("Lozinka i LozinkaPotvrda moraju biti iste");
                }

                entity.Salt = GenerateSalt();
                entity.Hash = GenerateHash(entity.Salt, request.Password);
            }
            else
            {
                var existingUser = Context.Korisniks.AsNoTracking().FirstOrDefault(x => x.Id == entity.Id);
                if (existingUser != null)
                {
                    entity.Salt = existingUser.Salt;
                    entity.Hash = existingUser.Hash;
                }
                else
                {
                    throw new Exception("Korisnik nije pronađen u bazi podataka.");
                }
            }
        }

        public Model.Korisnik Login(string username, string password)
        {
            var entity = Context.Korisniks.Include(x => x.TipKorisnika).FirstOrDefault(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }
            var hash = GenerateHash(entity.Salt, password);

            if (hash != entity.Hash)
            {
                return null;
            }

            return this.Mapper.Map<Model.Korisnik>(entity);
        }
    }
}

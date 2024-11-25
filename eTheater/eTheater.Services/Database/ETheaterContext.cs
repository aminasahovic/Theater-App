using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace eTheater.Services.Database;

public partial class ETheaterContext : DbContext
{
    public ETheaterContext()
    {
    }

    public ETheaterContext(DbContextOptions<ETheaterContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Glumac> Glumacs { get; set; }

    public virtual DbSet<GlumacPredstava> GlumacPredstavas { get; set; }

    public virtual DbSet<Izvedba> Izvedbas { get; set; }

    public virtual DbSet<IzvedbaSjediste> IzvedbaSjedistes { get; set; }

    public virtual DbSet<KomentarObavijest> KomentarObavijests { get; set; }

    public virtual DbSet<KomentarPrestava> KomentarPrestavas { get; set; }

    public virtual DbSet<Korisnik> Korisniks { get; set; }

    public virtual DbSet<Obavijest> Obavijests { get; set; }

    public virtual DbSet<OdgovorKomentar> OdgovorKomentars { get; set; }

    public virtual DbSet<Predstava> Predstavas { get; set; }

    public virtual DbSet<Repertoar> Repertoars { get; set; }

    public virtual DbSet<RepertoarIzvedba> RepertoarIzvedbas { get; set; }

    public virtual DbSet<Rezervacija> Rezervacijas { get; set; }

    public virtual DbSet<Reziser> Rezisers { get; set; }

    public virtual DbSet<Sala> Salas { get; set; }

    public virtual DbSet<Sjediste> Sjedistes { get; set; }

    public virtual DbSet<TipKorisnik> TipKorisniks { get; set; }

    public virtual DbSet<Zanr> Zanrs { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=DESKTOP-D580MSN;Initial Catalog=eTheater;TrustServerCertificate=True;Trusted_Connection=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Glumac>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Glumac__3214EC27ECF8086B");

            entity.ToTable("Glumac");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Ime)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Prezime)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Slika).HasColumnType("text");
        });

        modelBuilder.Entity<GlumacPredstava>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__GlumacPr__3214EC27222F1E2B");

            entity.ToTable("GlumacPredstava");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.GlumacId).HasColumnName("GlumacID");
            entity.Property(e => e.PredstavaId).HasColumnName("PredstavaID");
            entity.Property(e => e.Uloga)
                .HasMaxLength(100)
                .IsUnicode(false);

            entity.HasOne(d => d.Glumac).WithMany(p => p.GlumacPredstavas)
                .HasForeignKey(d => d.GlumacId)
                .HasConstraintName("FK__GlumacPre__Gluma__48CFD27E");

            entity.HasOne(d => d.Predstava).WithMany(p => p.GlumacPredstavas)
                .HasForeignKey(d => d.PredstavaId)
                .HasConstraintName("FK__GlumacPre__Preds__49C3F6B7");
        });

        modelBuilder.Entity<Izvedba>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Izvedba__3214EC278180A4E4");

            entity.ToTable("Izvedba");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.CijenaKarte).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.DatumVrijeme).HasColumnType("datetime");
            entity.Property(e => e.PredstavaId).HasColumnName("PredstavaID");
            entity.Property(e => e.SalaId).HasColumnName("SalaID");

            entity.HasOne(d => d.Predstava).WithMany(p => p.Izvedbas)
                .HasForeignKey(d => d.PredstavaId)
                .HasConstraintName("FK__Izvedba__Predsta__5EBF139D");

            entity.HasOne(d => d.Sala).WithMany(p => p.Izvedbas)
                .HasForeignKey(d => d.SalaId)
                .HasConstraintName("FK__Izvedba__SalaID__5FB337D6");
        });

        modelBuilder.Entity<IzvedbaSjediste>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__IzvedbaS__3214EC27F700CBD9");

            entity.ToTable("IzvedbaSjediste");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.IzvedbaId).HasColumnName("IzvedbaID");
            entity.Property(e => e.SjedisteId).HasColumnName("SjedisteID");
            entity.Property(e => e.Status)
                .HasMaxLength(20)
                .IsUnicode(false)
                .HasDefaultValue("Slobodno");

            entity.HasOne(d => d.Izvedba).WithMany(p => p.IzvedbaSjedistes)
                .HasForeignKey(d => d.IzvedbaId)
                .HasConstraintName("FK__IzvedbaSj__Izved__6383C8BA");

            entity.HasOne(d => d.Sjediste).WithMany(p => p.IzvedbaSjedistes)
                .HasForeignKey(d => d.SjedisteId)
                .HasConstraintName("FK__IzvedbaSj__Sjedi__6477ECF3");
        });

        modelBuilder.Entity<KomentarObavijest>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Komentar__3214EC27F2620998");

            entity.ToTable("KomentarObavijest");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Datum)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.ObavijestId).HasColumnName("ObavijestID");
            entity.Property(e => e.Text).HasColumnType("text");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KomentarObavijests)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__KomentarO__Koris__52593CB8");

            entity.HasOne(d => d.Obavijest).WithMany(p => p.KomentarObavijests)
                .HasForeignKey(d => d.ObavijestId)
                .HasConstraintName("FK__KomentarO__Obavi__5165187F");
        });

        modelBuilder.Entity<KomentarPrestava>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Komentar__3214EC271968B1BE");

            entity.ToTable("KomentarPrestava");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Datum)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Komentar).HasColumnType("text");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.PredstavaId).HasColumnName("PredstavaID");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.KomentarPrestavas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__KomentarP__Koris__68487DD7");

            entity.HasOne(d => d.Predstava).WithMany(p => p.KomentarPrestavas)
                .HasForeignKey(d => d.PredstavaId)
                .HasConstraintName("FK__KomentarP__Preds__693CA210");
        });

        modelBuilder.Entity<Korisnik>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Korisnik__3214EC27C049D4CD");

            entity.ToTable("Korisnik");

            entity.HasIndex(e => e.Username, "UQ__Korisnik__536C85E4D9AF80EA").IsUnique();

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.BrojTelefona)
                .HasMaxLength(20)
                .IsUnicode(false);
            entity.Property(e => e.Ime)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Password)
                .HasMaxLength(255)
                .IsUnicode(false);
            entity.Property(e => e.Prezime)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Salt)
                .HasMaxLength(255)
                .IsUnicode(false);
            entity.Property(e => e.TipKorisnikaId).HasColumnName("TipKorisnikaID");
            entity.Property(e => e.Username)
                .HasMaxLength(50)
                .IsUnicode(false);

            entity.HasOne(d => d.TipKorisnika).WithMany(p => p.Korisniks)
                .HasForeignKey(d => d.TipKorisnikaId)
                .HasConstraintName("FK__Korisnik__TipKor__3B75D760");
        });

        modelBuilder.Entity<Obavijest>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Obavijes__3214EC278B3E6B71");

            entity.ToTable("Obavijest");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.DatumObjave)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DatumUredjivanja).HasColumnType("datetime");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.Naslov)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Sadrzaj).HasColumnType("text");
            entity.Property(e => e.Slika).HasColumnType("text");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Obavijests)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Obavijest__Koris__4D94879B");
        });

        modelBuilder.Entity<OdgovorKomentar>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__OdgovorK__3214EC271A2A133C");

            entity.ToTable("OdgovorKomentar");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Datum)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.KomentariObavijestiId).HasColumnName("KomentariObavijestiID");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.TextOdgovora).HasColumnType("text");

            entity.HasOne(d => d.KomentariObavijesti).WithMany(p => p.OdgovorKomentars)
                .HasForeignKey(d => d.KomentariObavijestiId)
                .HasConstraintName("FK__OdgovorKo__Komen__5629CD9C");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.OdgovorKomentars)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__OdgovorKo__Koris__571DF1D5");
        });

        modelBuilder.Entity<Predstava>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Predstav__3214EC27F3BBC9E2");

            entity.ToTable("Predstava");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.Naziv)
                .HasMaxLength(100)
                .IsUnicode(false);
            entity.Property(e => e.Opis).HasColumnType("text");
            entity.Property(e => e.Plakat).HasColumnType("text");
            entity.Property(e => e.ReziserId).HasColumnName("ReziserID");
            entity.Property(e => e.ZanrId).HasColumnName("ZanrID");

            entity.HasOne(d => d.Reziser).WithMany(p => p.Predstavas)
                .HasForeignKey(d => d.ReziserId)
                .HasConstraintName("FK__Predstava__Rezis__440B1D61");

            entity.HasOne(d => d.Zanr).WithMany(p => p.Predstavas)
                .HasForeignKey(d => d.ZanrId)
                .HasConstraintName("FK__Predstava__ZanrI__4316F928");
        });

        modelBuilder.Entity<Repertoar>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Repertoa__3214EC271D81A298");

            entity.ToTable("Repertoar");

            entity.Property(e => e.Id).HasColumnName("ID");
        });

        modelBuilder.Entity<RepertoarIzvedba>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Repertoa__3214EC2759C0C313");

            entity.ToTable("RepertoarIzvedba");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.IzvedbaId).HasColumnName("IzvedbaID");
            entity.Property(e => e.RepertoarId).HasColumnName("RepertoarID");

            entity.HasOne(d => d.Izvedba).WithMany(p => p.RepertoarIzvedbas)
                .HasForeignKey(d => d.IzvedbaId)
                .HasConstraintName("FK__Repertoar__Izved__6EF57B66");

            entity.HasOne(d => d.Repertoar).WithMany(p => p.RepertoarIzvedbas)
                .HasForeignKey(d => d.RepertoarId)
                .HasConstraintName("FK__Repertoar__Reper__6E01572D");
        });

        modelBuilder.Entity<Rezervacija>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Rezervac__3214EC270769BD58");

            entity.ToTable("Rezervacija");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.IsKupljeno).HasDefaultValue(false);
            entity.Property(e => e.IsUsedTicket)
                .HasDefaultValue(false)
                .HasColumnName("isUsedTicket");
            entity.Property(e => e.IzvedbaId).HasColumnName("IzvedbaID");
            entity.Property(e => e.KorisnikId).HasColumnName("KorisnikID");
            entity.Property(e => e.PaymentId)
                .HasMaxLength(50)
                .IsUnicode(false)
                .HasColumnName("PaymentID");

            entity.HasOne(d => d.Izvedba).WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.IzvedbaId)
                .HasConstraintName("FK__Rezervaci__Izved__74AE54BC");

            entity.HasOne(d => d.Korisnik).WithMany(p => p.Rezervacijas)
                .HasForeignKey(d => d.KorisnikId)
                .HasConstraintName("FK__Rezervaci__Koris__73BA3083");
        });

        modelBuilder.Entity<Reziser>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Reziser__3214EC278C3A28BA");

            entity.ToTable("Reziser");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Ime)
                .HasMaxLength(50)
                .IsUnicode(false);
            entity.Property(e => e.Prezime)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Sala>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Sala__3214EC275BB4078C");

            entity.ToTable("Sala");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Sjediste>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Sjediste__3214EC27AA841CF8");

            entity.ToTable("Sjediste");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.SalaId).HasColumnName("SalaID");

            entity.HasOne(d => d.Sala).WithMany(p => p.Sjedistes)
                .HasForeignKey(d => d.SalaId)
                .HasConstraintName("FK__Sjediste__SalaID__5BE2A6F2");
        });

        modelBuilder.Entity<TipKorisnik>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__TipKoris__3214EC271B36FC8C");

            entity.ToTable("TipKorisnik");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        modelBuilder.Entity<Zanr>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Zanr__3214EC277606F7F1");

            entity.ToTable("Zanr");

            entity.Property(e => e.Id).HasColumnName("ID");
            entity.Property(e => e.Naziv)
                .HasMaxLength(50)
                .IsUnicode(false);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

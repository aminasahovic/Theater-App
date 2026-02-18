import { ComponentFixture, TestBed } from '@angular/core/testing';

import { KomentariPredstaveScreen } from './komentari-predstave-screen';

describe('KomentariPredstaveScreen', () => {
  let component: KomentariPredstaveScreen;
  let fixture: ComponentFixture<KomentariPredstaveScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [KomentariPredstaveScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(KomentariPredstaveScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

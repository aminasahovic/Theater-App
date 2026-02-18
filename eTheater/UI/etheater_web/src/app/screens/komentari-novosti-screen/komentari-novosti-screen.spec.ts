import { ComponentFixture, TestBed } from '@angular/core/testing';

import { KomentariNovostiScreen } from './komentari-novosti-screen';

describe('KomentariNovostiScreen', () => {
  let component: KomentariNovostiScreen;
  let fixture: ComponentFixture<KomentariNovostiScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [KomentariNovostiScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(KomentariNovostiScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

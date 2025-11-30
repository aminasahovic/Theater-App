import { ComponentFixture, TestBed } from '@angular/core/testing';

import { PredstavaScreen } from './predstava-screen';

describe('PredstavaScreen', () => {
  let component: PredstavaScreen;
  let fixture: ComponentFixture<PredstavaScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PredstavaScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PredstavaScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

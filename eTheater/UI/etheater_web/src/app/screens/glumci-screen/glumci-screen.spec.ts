import { ComponentFixture, TestBed } from '@angular/core/testing';

import { GlumciScreen } from './glumci-screen';

describe('GlumciScreen', () => {
  let component: GlumciScreen;
  let fixture: ComponentFixture<GlumciScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [GlumciScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(GlumciScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

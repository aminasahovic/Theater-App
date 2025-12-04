import { ComponentFixture, TestBed } from '@angular/core/testing';

import { ReziseriScreen } from './reziseri-screen';

describe('ReziseriScreen', () => {
  let component: ReziseriScreen;
  let fixture: ComponentFixture<ReziseriScreen>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [ReziseriScreen]
    })
    .compileComponents();

    fixture = TestBed.createComponent(ReziseriScreen);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

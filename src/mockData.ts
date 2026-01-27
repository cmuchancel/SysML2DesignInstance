import { ResistorResult } from "./types.js";

export const mockResistors: ResistorResult[] = [
  {
    manufacturer: "Yageo",
    manufacturerPartNumber: "RC0603FR-0710KL",
    digiKeyPartNumber: "311-10.0KHRCT-ND",
    description: "RES SMD 10K OHM 1% 1/10W 0603",
    stock: 125000,
    unitPrice: 0.012,
    url: "https://www.digikey.com/en/products/detail/yageo/RC0603FR-0710KL/727385",
    attributes: {
      resistance: "10 kOhms",
      tolerance: "±1%",
      power: "0.1W",
      package: "0603 (1608 Metric)",
      composition: "Thick Film",
    },
  },
  {
    manufacturer: "Vishay Dale",
    manufacturerPartNumber: "CRCW0603100KFKEA",
    digiKeyPartNumber: "541-100KLCT-ND",
    description: "RES SMD 100K OHM 1% 1/10W 0603",
    stock: 84000,
    unitPrice: 0.015,
    url: "https://www.digikey.com/en/products/detail/vishay-dale/CRCW0603100KFKEA/1174590",
    attributes: {
      resistance: "100 kOhms",
      tolerance: "±1%",
      power: "0.1W",
      package: "0603 (1608 Metric)",
      composition: "Thick Film",
    },
  },
  {
    manufacturer: "Panasonic",
    manufacturerPartNumber: "ERJ-2RKF1002X",
    digiKeyPartNumber: "P10.0KBDCT-ND",
    description: "RES SMD 10K OHM 1% 1/10W 0402",
    stock: 62000,
    unitPrice: 0.01,
    url: "https://www.digikey.com/en/products/detail/panasonic-electronic-components/ERJ-2RKF1002X/1468253",
    attributes: {
      resistance: "10 kOhms",
      tolerance: "±1%",
      power: "0.1W",
      package: "0402 (1005 Metric)",
      composition: "Thick Film",
    },
  },
];

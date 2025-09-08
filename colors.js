// Install first: npm install colorjs.io
import Color from "colorjs.io";

const colors = {
  Donkerblauw: [12, 35, 64],
  Turkoois: [0, 184, 200],
  Koningsblauw: [0, 118, 194],
  Paars: [111, 29, 119],
  Roze: [239, 96, 163],
  Bordeaux: [165, 0, 52],
  Rood: [224, 60, 49],
  Oranje: [237, 104, 66],
  Geel: [255, 184, 28],
  Groen: [108, 194, 74],
  Bosgroen: [0, 155, 119],
  Donkergrijs: [92, 92, 92]
};

// Function to convert to OKLCH and create muted variant
function convertAndMute(rgb, muteFactor = 0.5, lightnessBoost = 0.05) {
  const c = new Color("srgb", rgb.map(v => v / 255));
  const oklch = c.to("oklch").coords;

  const [L, C, h] = oklch;

  // Reduce saturation (chroma) and slightly increase lightness
  const muted = [
    Math.min(L + lightnessBoost, 1),
    C * muteFactor,
    h
  ];

  return {
    oklch: { L: L.toFixed(4), C: C.toFixed(4), h: h.toFixed(2) },
    muted: {
      L: muted[0].toFixed(4),
      C: muted[1].toFixed(4),
      h: muted[2].toFixed(2)
    },
    css: {
      normal: new Color("oklch", oklch).to("srgb").toString({ format: "hex" }),
      muted: new Color("oklch", muted).to("srgb").toString({ format: "hex" })
    }
  };
}

// Run conversion
for (const [name, rgb] of Object.entries(colors)) {
  const result = convertAndMute(rgb, 0.4, 0.07); // adjust factors as needed
  console.log(name, result);
}

/**
 * countryService.ts
 * Local country metadata lookup.
 *
 * Country information is intentionally stored locally:
 * - avoids runtime API dependencies
 * - avoids CORS problems
 * - improves notebook loading speed
 */

export interface CountryMetadata {
  name: string;
  flagUrl: string;
  code: string;
}

const COUNTRIES: Record<string, CountryMetadata> = {
  mexico: {
    name: "Mexico",
    flagUrl: "https://flagcdn.com/w320/mx.png",
    code: "MX"
  },

  japan: {
    name: "Japan",
    flagUrl: "https://flagcdn.com/w320/jp.png",
    code: "JP"
  },

  thailand: {
    name: "Thailand",
    flagUrl: "https://flagcdn.com/w320/th.png",
    code: "TH"
  },

  brazil: {
    name: "Brazil",
    flagUrl: "https://flagcdn.com/w320/br.png",
    code: "BR"
  }
};


export async function getCountryMetadata(
  countryName: string
): Promise<CountryMetadata> {

  const normalized = countryName.trim().toLowerCase();

  return (
    COUNTRIES[normalized] ?? {
      name: countryName,
      flagUrl: "https://flagcdn.com/w320/un.png",
      code: "UN"
    }
  );
}


export function getFlagUrlByCode(code: string): string {
  return `https://flagcdn.com/w160/${code.toLowerCase()}.png`;
}
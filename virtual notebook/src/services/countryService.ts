/**
 * countryService.ts
 * Dynamic lookup for country metadata and flags.
 */

export interface CountryMetadata {
  name: string;
  flagUrl: string;
  code: string;
}

// Fallback just in case, but preferred to fetch dynamically
export async function getCountryMetadata(countryName: string): Promise<CountryMetadata> {
  try {
    const response = await fetch(`https://restcountries.com/v3.1/name/${encodeURIComponent(countryName)}?fullText=true`);
    if (!response.ok) throw new Error('Country not found');
    
    const data = await response.json();
    const country = data[0];
    
    return {
      name: country.name.common,
      flagUrl: country.flags.svg || country.flags.png,
      code: country.cca2
    };
  } catch (error) {
    // Return a generic fallback if fetch fails
    return {
      name: countryName,
      flagUrl: `https://flagcdn.com/w320/un.png`, // UN flag as fallback
      code: 'UN'
    };
  }
}

export function getFlagUrlByCode(code: string): string {
  return `https://flagcdn.com/w160/${code.toLowerCase()}.png`;
}

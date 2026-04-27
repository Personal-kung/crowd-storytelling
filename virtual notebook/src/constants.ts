import { Story } from './types';

export const SAMPLE_STORIES: Story[] = [
  {
    id: '1',
    title: 'The Silent Garden',
    name: 'Yuki Tanaka',
    country: 'Japan',
    text_content: 'In the heart of Kyoto, there lies a garden that speaks only in whispers. The moss grows thick over ancient stones, and the koi swim in patterns that mirror the constellations. One morning, a single white petal fell from the cherry tree. It did not drift; it danced. It seemed to know exactly where it was going, as if the wind itself was a choreographed partner. The silence was not empty. It was full of the sound of growing things, of the sun warming the earth, and of the memories of those who had walked these paths centuries ago. As the seasons shift, the garden transforms, yet its soul remains constant, a sanctuary for those seeking peace in a restless world. Beyond the bamboo fence, the world rushes by, but here, time slows to the pace of a falling leaf. Every stone has a story, every ripple on the pond a poem waiting to be written by the observant eye.',
    timestamp: new Date(),
    contact: 'yuki@example.com',
    status: 'published',
    type: 'fiction',
    coverImage: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?auto=format&fit=crop&q=80&w=1000'
  },
  {
    id: '2',
    title: 'Sands of Time',
    name: 'Amir Hassan',
    country: 'Egypt',
    text_content: 'The desert does not forget. Every grain of sand is a witness to the rise and fall of empires. Under the silver moon, the dunes shift like sleeping giants, whispering secrets to the wind. I found the amulet buried beneath a palm tree that shouldn\'t have been there. It glowed with a faint, rhythmic light, pulsing like a heart made of lapis lazuli, cold yet vibrant. As I touched it, the air grew cold. The scent of ancient incense filled my lungs, and for a moment, I saw the city as it was—vibrant, golden, and eternal, rising from the dust of millennia. The Nile flowed not with water, but with liquid starlight, and the pyramids were not tombs, but beacons reaching for the heavens. I understood then that history is not a line, but a circle.',
    timestamp: new Date(),
    contact: 'amir@example.com',
    status: 'published',
    type: 'fiction',
    coverImage: 'https://images.unsplash.com/photo-1503177119275-0aa32b3a9368?auto=format&fit=crop&q=80&w=1000'
  }
];

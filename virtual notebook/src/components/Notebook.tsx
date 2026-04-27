import { motion, AnimatePresence } from 'motion/react';
import React, { useState, useMemo, useEffect, useRef } from 'react';
import { Story } from '../types';
import { ChevronLeft, ChevronRight, X, BookOpen, Loader2, Globe, ChevronDown, Moon, Sun, ArrowLeft } from 'lucide-react';
import { transcreateStory } from '../services/transcreationService';
import { GoogleGenAI } from "@google/genai";

interface NotebookProps {
  stories: Story[];
  globalPages: any[];
  theme: 'light' | 'dark';
  onThemeToggle: () => void;
  currentPage: number;
  setCurrentPage: React.Dispatch<React.SetStateAction<number>>;
  isOpen: boolean;
  setIsOpen: React.Dispatch<React.SetStateAction<boolean>>;
}

const COUNTRY_TO_FLAG: Record<string, string> = {
  'Japan': '🇯🇵', 'Egypt': '🇪🇬', 'Brazil': '🇧🇷', 'Mexico': '🇲🇽', 'India': '🇮🇳', 
  'China': '🇨🇳', 'France': '🇫🇷', 'Canada': '🇨🇦', 'Australia': '🇦🇺', 'Nigeria': '🇳🇬', 
  'Spain': '🇪🇸', 'Germany': '🇩🇪', 'Italy': '🇮🇹', 'UK': '🇬🇧', 'USA': '🇺🇸', 
  'South Korea': '🇰🇷', 'Netherlands': '🇳🇱', 'Norway': '🇳🇴', 'Greece': '🇬🇷', 
  'Ireland': '🇮🇪', 'Argentina': '🇦🇷', 'Portugal': '🇵🇹', 'Vietnam': '🇻🇳', 'Thailand': '🇹🇭',
  'Russia': '🇷🇺', 'South Africa': '🇿🇦', 'Turkey': '🇹🇷', 'Unknown': '🏳️'
};

const LANGUAGES = [
  { label: 'English', value: 'English' },
  { label: '日本語 (Japanese)', value: 'Japanese' },
  { label: 'Español (Spanish)', value: 'Spanish' },
  { label: '中文 (Mandarin)', value: 'Mandarin' },
  { label: 'العربية (Arabic)', value: 'Arabic' },
  { label: 'Other...', value: 'other' }
];

export default function Notebook({ 
  stories,
  globalPages,
  theme,
  onThemeToggle,
  currentPage,
  setCurrentPage,
  isOpen,
  setIsOpen,
}: NotebookProps) {
  const [selectedStory, setSelectedStory] = useState<Story | null>(null);
  const [isFlipping, setIsFlipping] = useState(false);
  const [isTranscreating, setIsTranscreating] = useState<Record<string, boolean>>({});
  const [localTranscreations, setLocalTranscreations] = useState<Record<string, Partial<Story>>>({});
  const [generatedImages, setGeneratedImages] = useState<Record<string, string>>({});
  const [isGenerating, setIsGenerating] = useState<Record<string, boolean>>({});
  const [showLanguageDropdown, setShowLanguageDropdown] = useState(false);
  const [customLanguage, setCustomLanguage] = useState('');
  const [isManualInput, setIsManualInput] = useState(false);
  const [quotaExceeded, setQuotaExceeded] = useState(false);
  const generatingRef = useRef<Set<string>>(new Set());

  const flipDuration = 0.5;

  const isCJK = (text: string) => /[\u4E00-\u9FFF\u3040-\u309F\u30A0-\u30FF]/.test(text);

  // Reset to first page when closing
  useEffect(() => {
    if (!isOpen) {
      setCurrentPage(0);
    }
  }, [isOpen, setCurrentPage]);

  const generateImage = async (story: Story) => {
    if (generatedImages[story.id] || story.coverImage || isGenerating[story.id] || quotaExceeded) return;
    if (generatingRef.current.has(story.id)) return;
    
    generatingRef.current.add(story.id);
    setIsGenerating(prev => ({ ...prev, [story.id]: true }));
    
    try {
      const apiKey = process.env.GEMINI_API_KEY;
      if (!apiKey) throw new Error("GEMINI_API_KEY not found in environment");

      const ai = new GoogleGenAI({ apiKey });
      const prompt = `Act as an artistic director. Create a high-quality, cinematic, and evocative cover image for a story titled "${story.title}". 
      Context: "${story.text_content?.substring(0, 500)}"
      Style: A beautiful, traditional painting or cinematic scene reflecting the culture of ${story.country}. 
      Composition: Centered, rich textures, deep emotional resonance. 
      Avoid any text, letters, or logos in the image.`;
      
      console.warn(`[DEBUG_IMAGE_GEN] >>> Prompt for story "${story.title}":`, prompt);
      
      const response = await ai.models.generateContent({
        model: "gemini-2.5-flash-image",
        contents: prompt,
        config: {
          imageConfig: {
            aspectRatio: "16:9"
          }
        }
      });
      
      console.warn(`[DEBUG_IMAGE_GEN] <<< Gemini Response for "${story.title}" received`);

      let imageUrl = "";
      if (response.candidates?.[0]?.content?.parts) {
        for (const part of response.candidates[0].content.parts) {
          if (part.inlineData) {
            imageUrl = `data:${part.inlineData.mimeType};base64,${part.inlineData.data}`;
            break;
          }
        }
      }
      
      if (imageUrl) {
        console.warn(`[DEBUG_IMAGE_GEN] === Generated image for story "${story.title}"`);
        setGeneratedImages(prev => ({ ...prev, [story.id]: imageUrl }));
      } else {
        console.warn(`[DEBUG_IMAGE_GEN] === No image found in response for "${story.title}". Text response:`, response.text);
      }
      
      setIsGenerating(prev => ({ ...prev, [story.id]: false }));
    } catch (error: any) {
      console.error('Error generating image:', error);
      const errorStr = JSON.stringify(error);
      if (errorStr.includes('429') || errorStr.includes('RESOURCE_EXHAUSTED')) {
        setQuotaExceeded(true);
        setTimeout(() => setQuotaExceeded(false), 60000);
      }
      setIsGenerating(prev => ({ ...prev, [story.id]: false }));
    } finally {
      generatingRef.current.delete(story.id);
    }
  };

  const goToPage = (pageIdx: number) => {
    if (pageIdx < 0 || pageIdx >= globalPages.length) return;
    setIsFlipping(true);
    setCurrentPage(pageIdx);
    setTimeout(() => setIsFlipping(false), flipDuration * 1000);
  };

  const nextPage = () => {
    if (currentPage < globalPages.length - 2) goToPage(currentPage + 2);
  };

  const prevPage = () => {
    if (currentPage > 0) goToPage(currentPage - 2);
  };

  const handleTranscreate = async (story: Story, language: string) => {
    if (isTranscreating[story.id]) return;
    setIsTranscreating(prev => ({ ...prev, [story.id]: true }));
    setShowLanguageDropdown(false);
    setIsManualInput(false);

    try {
      const result = await transcreateStory(story.title, story.text_content, language);
      setLocalTranscreations(prev => ({
        ...prev,
        [story.id]: {
          ...prev[story.id],
          transcreated_content: result.transcreatedText,
          writingMode: result.writingMode,
          localizedCountry: result.localizedCountry 
        }
      }));
    } catch (err) {
      console.error("Transcreation error:", err);
    } finally {
      setIsTranscreating(prev => ({ ...prev, [story.id]: false }));
    }
  };

  const getStoryData = (storyIdx: number) => {
    const original = stories[storyIdx];
    if (!original) return null;
    const transcreation = localTranscreations[original.id];
    const generatedImage = generatedImages[original.id];
    
    const combined = {
      ...original,
      ...transcreation,
      coverImage: original.coverImage || generatedImage
    } as Story;

    // Auto-detect vertical writing for CJK if not explicitly set
    if (!combined.writingMode && isCJK(combined.transcreated_content || combined.text_content || '')) {
      combined.writingMode = 'vertical-rl';
    }

    return combined;
  };

  const leftPage = globalPages[currentPage];
  const rightPage = globalPages[currentPage + 1];

  // Auto-generate images for visible pages
  useEffect(() => {
    if (!isOpen) return;
    const triggerGen = (page: any) => {
      if (page?.type === 'story' && page?.storyIndex !== undefined) {
        const story = stories[page.storyIndex];
        if (story && !story.coverImage && !generatedImages[story.id]) {
          generateImage(story);
        }
      }
    };
    triggerGen(leftPage);
    triggerGen(rightPage);
  }, [isOpen, currentPage, stories, leftPage, rightPage, generatedImages]);

  if (!isOpen) {
    return (
      <motion.div 
        layoutId="notebook"
        onClick={() => setIsOpen(true)}
        className="w-72 h-[500px] bg-stone-900 rounded-r-2xl rounded-l-md shadow-2xl cursor-pointer hover:rotate-[-2deg] transition-all relative group border-l-[12px] border-stone-950 flex flex-col justify-center items-center text-center p-8"
      >
        <div className="absolute inset-0 opacity-20 bg-[url('https://www.transparenttextures.com/patterns/leather.png')]" />
        <BookOpen className="text-amber-500/40 mb-6 group-hover:scale-110 transition-transform" size={56} />
        <h1 className="text-amber-50 font-serif italic text-3xl leading-tight">The Digital Ancestral Vessel</h1>
        <div className="w-12 h-0.5 bg-amber-500/20 mt-6" />
        <p className="text-amber-200/30 text-[10px] mt-6 uppercase tracking-[0.3em]">Open the Archive</p>
      </motion.div>
    );
  }

  const currentSelection = selectedStory ? (localTranscreations[selectedStory.id] ? { ...selectedStory, ...localTranscreations[selectedStory.id], coverImage: selectedStory.coverImage || generatedImages[selectedStory.id] } : { ...selectedStory, coverImage: selectedStory.coverImage || generatedImages[selectedStory.id] }) as Story : null;

  return (
    <div className="relative w-full h-full flex items-center justify-center">
      <AnimatePresence mode="wait">
        {!selectedStory ? (
          <motion.div 
            key="notebook-view"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 1.1 }}
            className="relative w-full max-w-6xl aspect-[4/3] flex items-center justify-center p-12"
          >
            {/* Explicit Gutter Navigation */}
            <div className="absolute left-4 top-0 bottom-0 flex items-center z-[70]">
              <button 
                onClick={prevPage}
                disabled={currentPage === 0}
                className="p-4 bg-stone-100 dark:bg-stone-800 text-stone-900 dark:text-stone-100 rounded-full shadow-2xl hover:scale-110 transition-all disabled:opacity-0 active:scale-95 border border-stone-200 dark:border-stone-700"
              >
                <ChevronLeft size={28} />
              </button>
            </div>
            <div className="absolute right-4 top-0 bottom-0 flex items-center z-[70]">
              <button 
                onClick={nextPage}
                disabled={currentPage >= globalPages.length - 2}
                className="p-4 bg-stone-100 dark:bg-stone-800 text-stone-900 dark:text-stone-100 rounded-full shadow-2xl hover:scale-110 transition-all disabled:opacity-0 active:scale-95 border border-stone-200 dark:border-stone-700"
              >
                <ChevronRight size={28} />
              </button>
            </div>

            <motion.div 
              layoutId="notebook"
              className="w-full h-full bg-parchment dark:bg-parchment-dark rounded-2xl flex shadow-[0_50px_100px_rgba(0,0,0,0.5)] relative overflow-hidden book-shadow border border-stone-200/50 dark:border-stone-800/50"
            >
              <div className="paper-grain absolute inset-0 z-0" />
              
              {/* Left Page */}
              <div className="flex-1 relative border-r border-stone-300 dark:border-stone-800 p-12 md:p-16 z-10 flex flex-col transition-colors duration-500 overflow-hidden">
                <PageContent 
                  page={leftPage} 
                  getStoryData={getStoryData}
                  stories={stories}
                  onSelect={setSelectedStory}
                  onGoToPage={goToPage}
                  globalPages={globalPages}
                />
              </div>

              {/* Gutter Binding Shadow */}
              <div className="absolute left-1/2 -translate-x-1/2 top-0 bottom-0 w-24 gutter-shadow z-20 pointer-events-none opacity-60" />

              {/* Right Page */}
              <div className="flex-1 relative p-12 md:p-16 z-10 flex flex-col transition-colors duration-500 overflow-hidden">
                <PageContent 
                  page={rightPage} 
                  getStoryData={getStoryData}
                  stories={stories}
                  onSelect={setSelectedStory}
                  onGoToPage={goToPage}
                  globalPages={globalPages}
                />
              </div>

              {/* Top Controls */}
              <div className="absolute top-8 right-8 flex gap-4 z-50">
                <button 
                  onClick={onThemeToggle} 
                  className="p-3 bg-stone-200/30 hover:bg-stone-200 dark:bg-stone-800/30 dark:hover:bg-stone-800 rounded-full transition-all text-stone-800 dark:text-stone-100"
                >
                  {theme === 'light' ? <Moon size={22} /> : <Sun size={22} />}
                </button>
                <button 
                  onClick={() => setIsOpen(false)} 
                  className="p-3 bg-rose-500/10 hover:bg-rose-500 text-rose-600 hover:text-white rounded-full transition-all"
                >
                  <X size={22} />
                </button>
              </div>

              {quotaExceeded && (
                <div className="absolute bottom-8 left-1/2 -translate-x-1/2 px-4 py-2 bg-amber-500 text-black text-xs font-bold rounded-full shadow-lg z-[100] animate-bounce">
                  AI Quota Resting (Try again in a minute)
                </div>
              )}
            </motion.div>
          </motion.div>
        ) : (
          <FullScreenStory 
            story={currentSelection!} 
            onClose={() => setSelectedStory(null)}
            onTranscreate={handleTranscreate}
            isTranscreating={isTranscreating[currentSelection!.id]}
            theme={theme}
            onThemeToggle={onThemeToggle}
          />
        )}
      </AnimatePresence>

      <style>{`
        .ink-in {
          animation: inkFlow 2s ease-out forwards;
        }
        @keyframes inkFlow {
          from { opacity: 0; filter: blur(10px); color: transparent; }
          to { opacity: 1; filter: blur(0); }
        }
        .paper-grain {
          background-image: url("https://www.transparenttextures.com/patterns/natural-paper.png");
          opacity: 0.15;
          filter: sepia(0.2);
        }
        .dark .paper-grain {
          filter: invert(1) brightness(0.5);
          opacity: 0.05;
        }
        .gutter-shadow {
          background: linear-gradient(to right, transparent, rgba(0,0,0,0.15) 50%, transparent);
        }
        .dark .gutter-shadow {
          background: linear-gradient(to right, transparent, rgba(255,255,255,0.05) 50%, transparent);
        }
        .book-shadow {
          box-shadow: 0 50px 100px -20px rgba(0, 0, 0, 0.4), 
                      0 30px 60px -30px rgba(0, 0, 0, 0.5);
        }
        .custom-scrollbar::-webkit-scrollbar { width: 5px; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.1); border-radius: 10px; }
      `}</style>
    </div>
  );
}

function PageContent({ page, getStoryData, stories, onSelect, onGoToPage, globalPages }: any) {
  if (!page) return null;

  if (page.type === 'toc') {
    return (
      <div className="flex flex-col h-full overflow-y-auto custom-scrollbar pr-4">
        <h2 className="text-4xl font-serif italic mb-12 border-b-2 border-stone-200 dark:border-stone-800 pb-6 text-black dark:text-stone-50">Ancestral Ledger</h2>
        <div className="space-y-10 flex-1">
          {stories.map((s: Story, idx: number) => {
            // Find the page index for this story
            const storyPageIndex = globalPages.findIndex((p: any) => p.type === 'story' && p.storyIndex === idx);
            
            return (
              <div 
                key={s.id} 
                className="group relative cursor-pointer"
                onClick={() => storyPageIndex !== -1 && onGoToPage(storyPageIndex)}
              >
                <span className="text-[10px] uppercase tracking-[0.4em] text-stone-600 dark:text-stone-400 block mb-2">Record #{idx + 1}</span>
                <h3 className="text-2xl font-serif italic group-hover:text-amber-700 dark:group-hover:text-amber-500 transition-colors uppercase tracking-tight leading-tight text-black dark:text-stone-50">
                  {s.title}
                </h3>
                <p className="text-xs text-stone-500 dark:text-stone-300 italic mt-2 italic flex items-center gap-2">
                  {COUNTRY_TO_FLAG[s.country.trim()] || "🏳️"} From the annals of {s.country}
                </p>
              </div>
            );
          })}
        </div>
      </div>
    );
  }

  const story = getStoryData(page.storyIndex);
  if (!story) return null;

  return (
    <motion.div 
      whileHover={{ scale: 1.02 }}
      onClick={() => onSelect(story)}
      className="flex flex-col h-full bg-stone-50 md:-m-16 dark:bg-stone-900 border-[16px] border-parchment dark:border-parchment-dark shadow-2xl overflow-hidden relative cursor-pointer group"
    >
      <div className="flex-1 relative">
         <img 
          src={story.coverImage || 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=1000'} 
          className="absolute inset-0 w-full h-full object-cover transition-transform duration-[20s] group-hover:scale-125"
          alt={story.title}
          referrerPolicy="no-referrer"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent" />
        <div className="absolute bottom-16 left-12 right-12 text-white">
          <span className="text-[10px] uppercase tracking-[0.5em] text-amber-400 mb-4 block opacity-0 group-hover:opacity-100 transition-opacity">Record Story</span>
          <h2 className="text-4xl md:text-5xl font-serif italic drop-shadow-2xl leading-[1.1]">{story.title}</h2>
          <div className="mt-6 flex items-center gap-3 opacity-0 group-hover:opacity-100 transition-all transform translate-y-4 group-hover:translate-y-0">
            <span className="text-xs font-serif italic text-white/80">By {story.name}</span>
            <span className="w-1 h-1 bg-white/40 rounded-full" />
            <span className="text-xs font-serif italic text-white/80">{COUNTRY_TO_FLAG[story.country.trim()] || '🏳️'} {story.localizedCountry || story.country}</span>
          </div>
        </div>
      </div>
    </motion.div>
  );
}

function FullScreenStory({ story, onClose, onTranscreate, isTranscreating, theme, onThemeToggle }: { 
  story: Story, 
  onClose: () => void, 
  onTranscreate: (s: Story, l: string) => void,
  isTranscreating: boolean,
  theme: 'light' | 'dark',
  onThemeToggle: () => void
}) {
  const [showLang, setShowLang] = useState(false);

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className="fixed inset-0 z-[100] bg-parchment dark:bg-parchment-dark overflow-y-auto custom-scrollbar"
    >
      <div className="paper-grain fixed inset-0 z-0 pointer-events-none" />
      
      {/* Header Controls */}
      <div className="fixed top-8 left-8 flex gap-4 z-[110]">
        <button 
          onClick={onClose}
          className="p-4 bg-stone-900 text-white rounded-full shadow-2xl hover:scale-110 active:scale-95 transition-all"
        >
          <ArrowLeft size={24} />
        </button>
      </div>

      <div className="fixed top-8 right-8 flex gap-4 z-[110]">
        <div className="relative">
          <button 
            onClick={() => setShowLang(!showLang)}
            disabled={isTranscreating}
            className="flex items-center gap-3 px-6 py-4 bg-stone-900 text-white rounded-full shadow-2xl hover:scale-105 active:scale-95 transition-all"
          >
            {isTranscreating ? <Loader2 size={20} className="animate-spin" /> : <Globe size={20} />}
            <span className="font-serif italic">Transcreate</span>
          </button>
          
          <AnimatePresence>
            {showLang && (
              <motion.div 
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: 15 }}
                className="absolute top-full right-0 mt-4 w-56 bg-stone-50 border border-stone-200 rounded-2xl shadow-2xl overflow-hidden p-2 flex flex-col gap-1 z-[120]"
              >
                {LANGUAGES.map(l => (
                  <button 
                    key={l.value}
                    onClick={() => {
                      onTranscreate(story, l.value);
                      setShowLang(false);
                    }}
                    className="w-full text-left px-4 py-3 hover:bg-stone-200 rounded-xl transition-colors font-serif text-sm text-black"
                  >
                    {l.label}
                  </button>
                ))}
              </motion.div>
            )}
          </AnimatePresence>
        </div>
        <button 
          onClick={onThemeToggle}
          className="p-4 bg-stone-100 dark:bg-stone-800 text-stone-900 dark:text-stone-100 rounded-full shadow-2xl border border-stone-200 dark:border-stone-700"
        >
          {theme === 'light' ? <Moon size={24} /> : <Sun size={24} />}
        </button>
      </div>

      {/* Hero Image */}
      <div className="w-full h-[70vh] relative overflow-hidden">
        <motion.img 
          initial={{ scale: 1.1 }}
          animate={{ scale: 1 }}
          transition={{ duration: 1.5, ease: "easeOut" }}
          src={story.coverImage || 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=2000'} 
          className="w-full h-full object-cover"
          alt={story.title}
          referrerPolicy="no-referrer"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-parchment dark:from-parchment-dark via-transparent to-transparent" />
      </div>

      {/* Content Section */}
      <div className="max-w-4xl mx-auto px-8 pb-32 -mt-32 relative z-10">
        <motion.div
           initial={{ opacity: 0, y: 40 }}
           animate={{ opacity: 1, y: 0 }}
           transition={{ delay: 0.5 }}
        >
          <span className="text-[12px] uppercase tracking-[0.6em] text-amber-600 dark:text-amber-500 font-bold mb-6 block text-center">Sacred Record</span>
          <h1 className="text-6xl md:text-8xl font-serif italic mb-16 text-center text-black dark:text-stone-50 leading-tight">
            {story.title}
          </h1>
          
          <div 
            className="prose prose-2xl dark:prose-invert mx-auto font-serif leading-loose text-black dark:text-stone-50"
            style={{ writingMode: (story as any).writingMode || 'horizontal-tb' }}
          >
            {(story.transcreated_content || story.text_content || '').split('\n\n').map((para, i) => (
              <motion.p 
                key={i}
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true, margin: "-100px" }}
                className="mb-12 text-2xl md:text-3xl ink-in text-justify leading-[2.0]"
              >
                {para}
              </motion.p>
            ))}
          </div>

          <div className="mt-32 pt-16 border-t border-stone-400 dark:border-stone-600 text-center">
            <p className="text-2xl font-serif italic text-black dark:text-stone-50 mb-6">
              By <span className="text-black dark:text-stone-50 font-bold">{story.name}</span>
            </p>
            <div className="flex items-center justify-center gap-4 text-xl text-black/60 dark:text-stone-300 tracking-widest uppercase font-serif">
              <span>{COUNTRY_TO_FLAG[story.country.trim()] || '🏳️'}</span>
              <span>{story.localizedCountry || story.country}</span>
            </div>
            <div className="mt-12 opacity-30 text-[10px] font-mono uppercase tracking-[1em]">END_OF_RECORD</div>
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}


import { motion, AnimatePresence, useScroll, useSpring, useTransform } from 'motion/react';
import React, { useState, useMemo, useEffect, useRef } from 'react';
import { Story } from '../types';
import { ChevronLeft, ChevronRight, X, BookOpen, Loader2, Globe, ChevronDown, Moon, Sun, ArrowLeft, Bookmark } from 'lucide-react';
import { transcreateStory } from '../services/transcreationService';
import { GoogleGenAI } from "@google/genai";
import { useInView } from 'react-intersection-observer';
import { getCountryMetadata, getFlagUrlByCode } from '../services/countryService';
import { heartbeat, InteractionType } from '../services/HeartbeatService';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const LANGUAGES = [
  { label: 'English', value: 'English' },
  { label: '日本語 (Japanese)', value: 'Japanese' },
  { label: 'Español (Spanish)', value: 'Spanish' },
  { label: '中文 (Mandarin)', value: 'Mandarin' },
  { label: 'العربية (Arabic)', value: 'Arabic' },
  { label: 'Other...', value: 'other' }
];

/**
 * JIT Image Component with blurred placeholder and dominant color
 */
const JITImage = ({ src, alt, className }: { src: string; alt: string; className?: string }) => {
  const { ref, inView } = useInView({
    triggerOnce: true,
    rootMargin: '150px',
  });

  return (
    <div ref={ref} className={cn("relative overflow-hidden bg-stone-200 dark:bg-stone-800", className)}>
      {!inView && <div className="absolute inset-0 watercolor-blur" />}
      {inView && (
        <motion.img
          initial={{ opacity: 0, filter: 'blur(10px)' }}
          animate={{ opacity: 1, filter: 'blur(0px)' }}
          src={src}
          alt={alt}
          className="w-full h-full object-cover"
          referrerPolicy="no-referrer"
        />
      )}
    </div>
  );
};

const DynamicFlag = ({ country }: { country: string }) => {
  const [flagUrl, setFlagUrl] = useState<string | null>(null);
  const { ref, inView } = useInView({ triggerOnce: true });

  useEffect(() => {
    if (inView && country) {
      getCountryMetadata(country).then(meta => setFlagUrl(meta.flagUrl));
    }
  }, [inView, country]);

  return (
    <span ref={ref} className="inline-flex items-center justify-center w-6 h-4 overflow-hidden rounded-sm bg-stone-100 dark:bg-stone-800">
      {flagUrl ? (
        <img src={flagUrl} alt={country} className="w-full h-full object-cover" />
      ) : (
        <span className="text-[10px]">🏳️</span>
      )}
    </span>
  );
};

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

  const [isMobile, setIsMobile] = useState(false);
  const [isLandscape, setIsLandscape] = useState(false);
  const [hoverStartTime, setHoverStartTime] = useState<number | null>(null);

  useEffect(() => {
    const checkViewport = () => {
      setIsMobile(window.innerWidth < 768);
      setIsLandscape(window.innerWidth > window.innerHeight && window.innerWidth < 1024);
    };
    checkViewport();
    window.addEventListener('resize', checkViewport);
    return () => window.removeEventListener('resize', checkViewport);
  }, []);

  const flipDuration = 0.5;

  const isCJK = (text: string) => /[\u4E00-\u9FFF\u3040-\u309F\u30A0-\u30FF]/.test(text);

  // Reset to first page when closing
  useEffect(() => {
    if (!isOpen) {
      setCurrentPage(0);
    }
  }, [isOpen, setCurrentPage]);

  // Engagement tracking
  useEffect(() => {
    if (isOpen) {
      heartbeat.log(InteractionType.PAGE_FLIP, { pageIndex: currentPage });
    }
  }, [currentPage, isOpen]);

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
          title: result.transcreatedTitle || story.title,
          originalTitle: story.title,
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
        <h1 className="text-amber-50 font-serif italic text-3xl leading-tight">The Stories from the World</h1>
        <div className="w-12 h-0.5 bg-amber-500/20 mt-6" />
        <p className="text-amber-200/30 text-[10px] mt-6 uppercase tracking-[0.3em]">Open the Archive</p>
      </motion.div>
    );
  }

  const currentSelection = selectedStory ? (localTranscreations[selectedStory.id] ? { ...selectedStory, ...localTranscreations[selectedStory.id], coverImage: selectedStory.coverImage || generatedImages[selectedStory.id] } : { ...selectedStory, coverImage: selectedStory.coverImage || generatedImages[selectedStory.id] }) as Story : null;

  return (
    <div 
      className="relative w-full h-full flex items-center justify-center p-4 md:p-12 overflow-hidden"
      onMouseEnter={() => setHoverStartTime(Date.now())}
      onMouseLeave={() => {
        if (hoverStartTime) {
          heartbeat.log(InteractionType.TACTILE_HOVER, { duration: Date.now() - hoverStartTime });
          setHoverStartTime(null);
        }
      }}
    >
      <AnimatePresence mode="wait">
        {!selectedStory ? (
          <motion.div 
            key="notebook-view"
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 1.1 }}
            className={cn(
              "relative w-full max-w-6xl flex items-center justify-center",
              !isMobile ? "aspect-[4/3]" : "h-full"
            )}
          >
            {/* Explicit Gutter Navigation (Spread only on Desktop) */}
            {!isMobile && (
              <>
                <div className="absolute left-4 top-0 bottom-0 flex items-center z-[70]">
                  <button 
                    onClick={prevPage}
                    disabled={currentPage === 0}
                    className="p-4 bg-stone-100 dark:bg-stone-800 text-stone-900 dark:text-stone-100 rounded-full shadow-2xl hover:scale-110 transition-all disabled:opacity-0 active:scale-95 border border-stone-200 dark:border-stone-700 peel-affordance-left outline-none"
                  >
                    <ChevronLeft size={28} />
                  </button>
                </div>
                <div className="absolute right-4 top-0 bottom-0 flex items-center z-[70]">
                  <button 
                    onClick={nextPage}
                    disabled={currentPage >= globalPages.length - 2}
                    className="p-4 bg-stone-100 dark:bg-stone-800 text-stone-900 dark:text-stone-100 rounded-full shadow-2xl hover:scale-110 transition-all disabled:opacity-0 active:scale-95 border border-stone-200 dark:border-stone-700 peel-affordance-right outline-none"
                  >
                    <ChevronRight size={28} />
                  </button>
                </div>
              </>
            )}

            {/* Mobile Bottom Navigation Bar */}
            {isMobile && (
              <div className="fixed bottom-0 left-0 right-0 h-20 bg-stone-900/90 backdrop-blur-md z-[150] flex items-center justify-around px-8 border-t border-white/10">
                <button 
                  onClick={prevPage}
                  disabled={currentPage === 0}
                  className="p-3 text-white disabled:opacity-30 outline-none"
                >
                  <ChevronLeft size={32} />
                </button>
                <div className="font-serif italic text-white/60 text-sm">
                  Page {currentPage + 1}
                </div>
                <button 
                  onClick={() => setIsOpen(false)}
                  className="p-3 bg-rose-600 text-white rounded-full shadow-lg outline-none"
                >
                  <X size={24} />
                </button>
                <button 
                  onClick={nextPage}
                  disabled={currentPage >= globalPages.length - 1}
                  className="p-3 text-white disabled:opacity-30 outline-none"
                >
                  <ChevronRight size={32} />
                </button>
              </div>
            )}

            <motion.div 
              layoutId="notebook"
              className={cn(
                "w-full h-full bg-parchment dark:bg-parchment-dark shadow-[0_50px_100px_rgba(0,0,0,0.5)] relative overflow-hidden book-shadow border border-stone-200/50 dark:border-stone-800/50",
                !isMobile ? "flex rounded-2xl" : "flex flex-col rounded-none"
              )}
            >
              <div className="paper-grain absolute inset-0 z-0" />

              {/* Silk Ribbon Bookmark (TOC Access) - Anchor to book container top-right */}
              <div 
                className={cn(
                  "absolute z-[40] pointer-events-none transition-all duration-500",
                  !isMobile ? "top-0 right-12 scale-100" : "top-0 right-6 scale-75"
                )}
              >
                <motion.div 
                  className="cursor-pointer group pointer-events-auto"
                  onClick={() => goToPage(0)}
                  whileHover={{ y: !isMobile ? 20 : 10 }}
                >
                  <div className={cn(
                    "bg-rose-700 dark:bg-rose-900 rounded-b-lg shadow-xl flex items-end justify-center transition-colors group-hover:bg-rose-600",
                    !isMobile ? "w-10 h-32 pb-4" : "w-8 h-24 pb-3"
                  )}>
                    <Bookmark className="text-white/80" size={!isMobile ? 20 : 16} />
                  </div>
                </motion.div>
              </div>
              
              {/* Left Page / Single Page on Mobile */}
              <div className={cn(
                "relative z-10 flex flex-col transition-colors duration-500 overflow-hidden",
                !isMobile 
                  ? "flex-1 border-r border-stone-300 dark:border-stone-800 p-12 md:p-16" 
                  : "w-full h-full p-8 pb-32"
              )}>
                <PageContent 
                  page={isMobile ? (globalPages[currentPage] || leftPage) : leftPage} 
                  getStoryData={getStoryData}
                  stories={stories}
                  onSelect={(s: Story) => {
                    heartbeat.log(InteractionType.TACTILE_LONG_PRESS, { storyId: s.id });
                    setSelectedStory(s);
                  }}
                  onGoToPage={goToPage}
                  globalPages={globalPages}
                />
                
                {/* Penciled Page Number */}
                <div className="absolute bottom-6 right-6 md:left-6 md:right-auto z-30 font-serif italic text-stone-900/30 dark:text-stone-100/30 text-xs translate-y-0">
                  {currentPage + 1}
                </div>
              </div>

              {/* Gutter Binding Shadow (Only desktop) */}
              {!isMobile && (
                <>
                  <div className="absolute left-1/2 -translate-x-1/2 top-0 bottom-0 w-24 gutter-shadow z-20 pointer-events-none opacity-60" />
                  
                  {/* Right Page */}
                  <div className="flex-1 relative p-12 md:p-16 z-10 flex flex-col transition-colors duration-500 overflow-hidden">
                    <PageContent 
                      page={rightPage} 
                      getStoryData={getStoryData}
                      stories={stories}
                      onSelect={(s: Story) => {
                        heartbeat.log(InteractionType.TACTILE_LONG_PRESS, { storyId: s.id });
                        setSelectedStory(s);
                      }}
                      onGoToPage={goToPage}
                      globalPages={globalPages}
                    />

                    {/* Penciled Page Number */}
                    <div className="absolute bottom-6 right-6 z-30 font-serif italic text-stone-900/30 dark:text-stone-100/30 text-xs">
                      {currentPage + 2}
                    </div>
                  </div>
                </>
              )}

              {/* Top Controls (Desktop/Tablet) */}
              {!isMobile && (
                <div className="absolute top-8 right-24 flex gap-4 z-50">
                  <button 
                    onClick={onThemeToggle} 
                    className="p-3 bg-stone-200/30 hover:bg-stone-200 dark:bg-stone-800/30 dark:hover:bg-stone-800 rounded-full transition-all text-icon dark:text-icon-dark"
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
              )}

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
            onPrev={stories.findIndex(s => s.id === selectedStory?.id) > 0 ? () => setSelectedStory(stories[stories.findIndex(s => s.id === selectedStory?.id) - 1]) : undefined}
            onNext={stories.findIndex(s => s.id === selectedStory?.id) < stories.length - 1 ? () => setSelectedStory(stories[stories.findIndex(s => s.id === selectedStory?.id) + 1]) : undefined}
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
          filter: invert(1) brightness(0.3) contrast(1.2);
          opacity: 0.1;
          background-image: url("https://www.transparenttextures.com/patterns/natural-paper.png");
        }
        .watercolor-blur {
          background: radial-gradient(circle at center, rgba(168, 162, 158, 0.4), transparent 70%);
          filter: blur(40px);
        }
        .peel-affordance-left {
          box-shadow: -10px 0 20px -10px rgba(0,0,0,0.3);
        }
        .peel-affordance-right {
          box-shadow: 10px 0 20px -10px rgba(0,0,0,0.3);
        }
        .font-handwriting {
          font-family: 'Dancing Script', 'Caveat', cursive;
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
        <h2 className="text-3xl md:text-4xl font-serif italic mb-12 border-b-2 border-stone-200 dark:border-stone-800 pb-6 text-ink dark:text-ink-dark">Ancestral Ledger</h2>
        <div className="space-y-10 flex-1">
          {stories.map((s: Story, idx: number) => {
            // Find the page index for this story
            const storyPageIndex = globalPages.findIndex((p: any) => p.type === 'story' && p.storyIndex === idx);
            
            return (
              <div 
                key={s.id} 
                className="group relative cursor-pointer"
                onClick={() => {
                  if (storyPageIndex !== -1) {
                    heartbeat.log(InteractionType.PAGE_FLIP, { targetStory: s.title });
                    onGoToPage(storyPageIndex);
                  }
                }}
              >
                <span className="text-[10px] uppercase tracking-[0.4em] text-ink/40 dark:text-ink-dark/40 block mb-2">Record #{idx + 1}</span>
                <h3 className="text-xl md:text-2xl font-serif italic group-hover:text-amber-700 dark:group-hover:text-amber-500 transition-colors uppercase tracking-tight leading-tight text-ink dark:text-ink-dark">
                  {s.title}
                </h3>
                <p className="text-xs text-ink/60 dark:text-ink-dark/60 italic mt-2 italic flex items-center gap-2">
                  <DynamicFlag country={s.country} /> From the annals of {s.country}
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
         <JITImage 
          src={story.coverImage || 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&q=80&w=1000'} 
          className="absolute inset-0 w-full h-full transition-transform duration-[20s] group-hover:scale-125"
          alt={story.title}
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/20 to-transparent" />
        <div className="absolute bottom-16 left-12 right-12 text-white">
          <span className="text-[10px] uppercase tracking-[0.5em] text-amber-400 mb-4 block opacity-0 group-hover:opacity-100 transition-opacity">Record Story</span>
          <h2 className="text-3xl md:text-5xl font-serif italic drop-shadow-2xl leading-[1.1]">{story.title}</h2>
          <div className="mt-6 flex items-center gap-3 opacity-0 group-hover:opacity-100 transition-all transform translate-y-4 group-hover:translate-y-0">
            <span className="text-xs font-serif italic text-white/80">By {story.name}</span>
            <span className="w-1 h-1 bg-white/40 rounded-full" />
            <span className="text-xs font-serif italic text-white/80 inline-flex items-center gap-2">
              <DynamicFlag country={story.country} /> {story.localizedCountry || story.country}
            </span>
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
  const [isMobile, setIsMobile] = useState(window.innerWidth < 768);

  const [isSmallMobile, setIsSmallMobile] = useState(window.innerWidth < 480);

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
      setIsSmallMobile(window.innerWidth < 480);
    };
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  return (
    <motion.div 
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      className={cn(
        "fixed inset-0 z-[100] bg-parchment dark:bg-parchment-dark",
        !isMobile ? "overflow-y-auto custom-scrollbar" : "flex flex-col"
      )}
    >
      <div className="paper-grain fixed inset-0 z-0 pointer-events-none" />
      
      {/* Header Controls */}
      <div className={cn(
        "fixed flex gap-4 z-[110]",
        !isMobile ? "top-8 left-8" : "top-4 left-4"
      )}>
        <button 
          onClick={onClose}
          className={cn(
            "p-4 bg-stone-900 text-white rounded-full shadow-2xl hover:scale-110 active:scale-95 transition-all",
            isMobile && "p-2 scale-75"
          )}
        >
          <ArrowLeft size={isMobile ? 20 : 24} />
        </button>
      </div>

      <div className={cn(
        "fixed flex gap-4 z-[110]",
        !isMobile ? "top-8 right-8" : "top-4 right-4"
      )}>
        <div className="relative">
          <button 
            onClick={() => setShowLang(!showLang)}
            disabled={isTranscreating}
            className={cn(
              "flex items-center gap-3 px-6 py-4 bg-stone-900 text-white rounded-full shadow-2xl hover:scale-105 active:scale-95 transition-all",
              isMobile && "px-4 py-2 scale-75"
            )}
          >
            {isTranscreating ? <Loader2 size={isMobile ? 16 : 20} className="animate-spin" /> : <Globe size={isMobile ? 16 : 20} />}
            <span className={cn("font-serif italic", isMobile && "text-sm")}>Transcreate</span>
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
        {!isMobile && (
          <button 
            onClick={onThemeToggle}
            className="p-4 bg-stone-100 dark:bg-stone-800 text-icon dark:text-icon-dark rounded-full shadow-2xl border border-stone-200 dark:border-stone-700"
          >
            {theme === 'light' ? <Moon size={24} /> : <Sun size={24} />}
          </button>
        )}
      </div>

      {/* Hero Image */}
      <div className={cn(
        "relative overflow-hidden shrink-0 block",
        !isMobile ? "w-full h-[70vh]" : "w-full h-[300px]"
      )}>
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
      <div className={cn(
        "relative z-10 custom-scrollbar block",
        !isMobile ? "max-w-4xl mx-auto px-8 pb-32 -mt-32" : "flex-1 overflow-y-auto px-6 py-10"
      )}>
        <motion.div
           initial={{ opacity: 0, y: 40 }}
           animate={{ opacity: 1, y: 0 }}
           transition={{ delay: 0.5 }}
        >
          <span className="text-[12px] uppercase tracking-[0.6em] text-amber-600 dark:text-amber-500 font-bold mb-6 block text-center">Sacred Record</span>
          
          <div className="mb-16 text-center space-y-4">
            <h1 className={cn(
              "font-serif italic text-ink dark:text-ink-dark leading-tight",
              !isMobile ? "text-4xl md:text-8xl" : "text-3xl"
            )}>
              {story.transcreated_content ? (story as any).originalTitle : story.title}
            </h1>
            {story.transcreated_content && (
              <>
                <div className="w-24 h-px bg-stone-300 dark:bg-stone-700 mx-auto my-6" />
                <h2 className={cn(
                  "font-serif italic text-ink/70 dark:text-ink-dark/70 leading-tight",
                  !isMobile ? "text-2xl md:text-4xl" : "text-xl"
                )}>
                  {story.title}
                </h2>
              </>
            )}
          </div>
          
          <div 
            className={cn(
              "prose dark:prose-invert mx-auto font-serif text-ink dark:text-ink-dark",
              !isMobile ? "prose-2xl leading-loose" : (isSmallMobile ? "text-[19px] leading-[1.65]" : "prose-lg leading-loose")
            )}
            style={{ writingMode: story.writingMode || 'horizontal-tb' }}
          >
            {(story.transcreated_content || story.text_content || '').split('\n\n').map((para, i) => (
              <motion.p 
                key={i}
                initial={{ opacity: 0 }}
                whileInView={{ opacity: 1 }}
                viewport={{ once: true, margin: "-100px" }}
                className={cn(
                  "mb-12 ink-in text-justify leading-[2.0]",
                  !isMobile ? "text-2xl md:text-3xl" : "text-lg"
                )}
              >
                {para}
              </motion.p>
            ))}
          </div>

          <div className="mt-32 pt-16 border-t border-stone-400 dark:border-stone-600 text-center">
            <p className={cn(
              "font-serif italic text-ink dark:text-ink-dark mb-6",
              !isMobile ? "text-2xl" : "text-lg"
            )}>
              By <span className="text-ink dark:text-ink-dark font-bold">{story.name}</span>
            </p>
            <div className={cn(
              "flex items-center justify-center gap-4 uppercase font-serif",
              !isMobile ? "text-xl tracking-widest" : "text-sm tracking-wide"
            )}>
              <DynamicFlag country={story.country} />
              <span>{story.localizedCountry || story.country}</span>
            </div>
            <div className="mt-12 opacity-30 text-[10px] font-mono uppercase tracking-[1em]">END_OF_RECORD</div>
          </div>
        </motion.div>
      </div>
    </motion.div>
  );
}


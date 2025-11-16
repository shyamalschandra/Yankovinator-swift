// TypeScript source for Yankovinator homepage interactivity
// Copyright (C) 2025, Shyamal Suhana Chandra

interface ParodyResponse {
    success: boolean;
    parody?: string[];
    error?: string;
}

class YankovinatorUI {
    private generateBtn: HTMLButtonElement | null;
    private originalLyrics: HTMLTextAreaElement | null;
    private parodyOutput: HTMLElement | null;
    private copyButtons: NodeListOf<HTMLButtonElement>;

    constructor() {
        this.generateBtn = document.getElementById('generateBtn') as HTMLButtonElement;
        this.originalLyrics = document.getElementById('originalLyrics') as HTMLTextAreaElement;
        this.parodyOutput = document.getElementById('parodyOutput');
        this.copyButtons = document.querySelectorAll('.copy-btn');

        this.init();
    }

    private init(): void {
        // Initialize event listeners
        if (this.generateBtn) {
            this.generateBtn.addEventListener('click', () => this.handleGenerate());
        }

        // Copy button functionality
        this.copyButtons.forEach(btn => {
            btn.addEventListener('click', () => this.handleCopy(btn));
        });

        // Smooth scroll for navigation links
        this.initSmoothScroll();

        // Intersection Observer for animations
        this.initScrollAnimations();

        // Add typing effect to code window
        this.initTypingEffect();

        // Add parallax effect to background
        this.initParallax();

        // Add interactive SVG animations
        this.initSVGAnimations();
    }

    private async handleGenerate(): Promise<void> {
        if (!this.originalLyrics || !this.parodyOutput || !this.generateBtn) return;

        const lyrics = this.originalLyrics.value.trim();
        if (!lyrics) {
            this.showError('Please enter some lyrics first!');
            return;
        }

        // Disable button and show loading
        this.generateBtn.disabled = true;
        this.generateBtn.innerHTML = '<span class="loading"></span> Generating...';
        this.parodyOutput.innerHTML = '<p class="placeholder">✨ Creating your parody with perfect syllable matching...</p>';

        try {
            // Simulate API call (in real implementation, this would call the actual API)
            const parody = await this.simulateParodyGeneration(lyrics);
            this.displayParody(parody);
        } catch (error) {
            this.showError('Failed to generate parody. Please try again.');
            console.error('Parody generation error:', error);
        } finally {
            this.generateBtn.disabled = false;
            this.generateBtn.innerHTML = '<span>Generate Parody</span><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>';
        }
    }

    private async simulateParodyGeneration(lyrics: string): Promise<string[]> {
        // Simulate API delay
        await new Promise(resolve => setTimeout(resolve, 2000));

        // Split lyrics into lines
        const lines = lyrics.split('\n').filter(line => line.trim());
        
        // Generate a simple parody (in production, this would call the actual API)
        const parodyLines = lines.map((line, index) => {
            // Simple word substitution for demo
            const words = line.split(' ');
            const substituted = words.map(word => {
                // Simple demo substitution
                const substitutions: { [key: string]: string } = {
                    'I': 'We',
                    'you': 'they',
                    'stay': 'play',
                    'grave': 'wave',
                    'die': 'fly',
                    'love': 'soar',
                    'want': 'need'
                };
                const lowerWord = word.toLowerCase().replace(/[^\w]/g, '');
                return substitutions[lowerWord] || word;
            });
            return substituted.join(' ');
        });

        return parodyLines;
    }

    private displayParody(parody: string[]): void {
        if (!this.parodyOutput) return;

        const formattedParody = parody.map(line => line.trim()).join('\n');
        this.parodyOutput.innerHTML = `<pre class="parody-text">${this.escapeHtml(formattedParody)}</pre>`;
        
        // Add fade-in animation
        this.parodyOutput.style.opacity = '0';
        setTimeout(() => {
            if (this.parodyOutput) {
                this.parodyOutput.style.transition = 'opacity 0.5s ease-in';
                this.parodyOutput.style.opacity = '1';
            }
        }, 10);
    }

    private showError(message: string): void {
        if (!this.parodyOutput) return;
        this.parodyOutput.innerHTML = `<p class="error">${this.escapeHtml(message)}</p>`;
    }

    private escapeHtml(text: string): string {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    private handleCopy(button: HTMLButtonElement): void {
        const codeBlock = button.parentElement?.querySelector('code');
        if (!codeBlock) return;

        const text = codeBlock.textContent || '';
        navigator.clipboard.writeText(text).then(() => {
            button.classList.add('copied');
            const originalHTML = button.innerHTML;
            button.innerHTML = '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 6L9 17l-5-5"/></svg>';
            
            setTimeout(() => {
                button.classList.remove('copied');
                button.innerHTML = originalHTML;
            }, 2000);
        }).catch(err => {
            console.error('Failed to copy:', err);
        });
    }

    private initSmoothScroll(): void {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                const href = (e.currentTarget as HTMLAnchorElement).getAttribute('href');
                if (!href || href === '#') return;
                
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
    }

    private initScrollAnimations(): void {
        const observerOptions: IntersectionObserverInit = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate-in');
                }
            });
        }, observerOptions);

        // Observe feature cards and step cards
        document.querySelectorAll('.feature-card, .step-card').forEach(card => {
            observer.observe(card);
        });
    }

    private initTypingEffect(): void {
        const typingElements = document.querySelectorAll('.typing');
        typingElements.forEach((element, index) => {
            const text = element.textContent || '';
            element.textContent = '';
            element.classList.remove('typing');
            
            setTimeout(() => {
                this.typeText(element as HTMLElement, text);
            }, index * 1000);
        });
    }

    private typeText = (element: HTMLElement, text: string, index: number = 0): void => {
        if (index < text.length) {
            element.textContent = text.substring(0, index + 1);
            setTimeout(() => this.typeText(element, text, index + 1), 50);
        }
    }

    private initParallax(): void {
        let ticking = false;

        window.addEventListener('scroll', () => {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    const scrolled = window.pageYOffset;
                    const parallaxElements = document.querySelectorAll('.floating-circle');
                    
                    parallaxElements.forEach((element, index) => {
                        const speed = 0.5 + (index * 0.1);
                        const yPos = -(scrolled * speed);
                        (element as SVGElement).style.transform = `translateY(${yPos}px)`;
                    });
                    
                    ticking = false;
                });
                ticking = true;
            }
        });
    }

    private initSVGAnimations(): void {
        // Add interactive hover effects to SVG icons
        const svgIcons = document.querySelectorAll('.feature-icon svg');
        svgIcons.forEach(icon => {
            icon.addEventListener('mouseenter', () => {
                icon.classList.add('svg-hover');
            });
            icon.addEventListener('mouseleave', () => {
                icon.classList.remove('svg-hover');
            });
        });

        // Animate logo on scroll
        const logo = document.querySelector('.logo-icon');
        if (logo) {
            window.addEventListener('scroll', () => {
                const rotation = window.pageYOffset * 0.1;
                (logo as SVGElement).style.transform = `rotate(${rotation}deg)`;
            });
        }

        // Navbar scroll effect
        this.initNavbarScroll();
    }

    private initNavbarScroll(): void {
        const navbar = document.querySelector('.navbar');
        if (!navbar) return;

        let lastScroll = 0;
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            
            if (currentScroll > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
            
            lastScroll = currentScroll;
        });
    }
}

// Initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new YankovinatorUI();
    });
} else {
    new YankovinatorUI();
}

// Add CSS classes for animations
const style = document.createElement('style');
style.textContent = `
    .parody-text {
        color: var(--text-primary);
        line-height: 1.8;
        margin: 0;
    }
    
    .error {
        color: #f5576c;
        font-style: italic;
    }
    
    .feature-card,
    .step-card {
        opacity: 0;
        transform: translateY(30px);
        transition: all 0.6s ease-out;
    }
    
    .feature-card.animate-in,
    .step-card.animate-in {
        opacity: 1;
        transform: translateY(0);
    }
    
    .svg-hover {
        transform: scale(1.1) rotate(5deg);
        transition: transform 0.3s ease;
    }
    
    .feature-icon svg {
        transition: transform 0.3s ease;
    }
`;
document.head.appendChild(style);

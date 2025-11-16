"use strict";
class YankovinatorUI {
    constructor() {
        this.typeText = (element, text, index = 0) => {
            if (index < text.length) {
                element.textContent = text.substring(0, index + 1);
                setTimeout(() => this.typeText(element, text, index + 1), 50);
            }
        };
        this.generateBtn = document.getElementById('generateBtn');
        this.originalLyrics = document.getElementById('originalLyrics');
        this.parodyOutput = document.getElementById('parodyOutput');
        this.copyButtons = document.querySelectorAll('.copy-btn');
        this.init();
    }
    init() {
        if (this.generateBtn) {
            this.generateBtn.addEventListener('click', () => this.handleGenerate());
        }
        this.copyButtons.forEach(btn => {
            btn.addEventListener('click', () => this.handleCopy(btn));
        });
        this.initSmoothScroll();
        this.initScrollAnimations();
        this.initTypingEffect();
        this.initParallax();
        this.initSVGAnimations();
    }
    async handleGenerate() {
        if (!this.originalLyrics || !this.parodyOutput || !this.generateBtn)
            return;
        const lyrics = this.originalLyrics.value.trim();
        if (!lyrics) {
            this.showError('Please enter some lyrics first!');
            return;
        }
        this.generateBtn.disabled = true;
        this.generateBtn.innerHTML = '<span class="loading"></span> Generating...';
        this.parodyOutput.innerHTML = '<p class="placeholder">✨ Creating your parody with perfect syllable matching...</p>';
        try {
            const parody = await this.simulateParodyGeneration(lyrics);
            this.displayParody(parody);
        }
        catch (error) {
            this.showError('Failed to generate parody. Please try again.');
            console.error('Parody generation error:', error);
        }
        finally {
            this.generateBtn.disabled = false;
            this.generateBtn.innerHTML = '<span>Generate Parody</span><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>';
        }
    }
    async simulateParodyGeneration(lyrics) {
        await new Promise(resolve => setTimeout(resolve, 2000));
        const lines = lyrics.split('\n').filter(line => line.trim());
        const parodyLines = lines.map((line, index) => {
            const words = line.split(' ');
            const substituted = words.map(word => {
                const substitutions = {
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
    displayParody(parody) {
        if (!this.parodyOutput)
            return;
        const formattedParody = parody.map(line => line.trim()).join('\n');
        this.parodyOutput.innerHTML = `<pre class="parody-text">${this.escapeHtml(formattedParody)}</pre>`;
        this.parodyOutput.style.opacity = '0';
        setTimeout(() => {
            if (this.parodyOutput) {
                this.parodyOutput.style.transition = 'opacity 0.5s ease-in';
                this.parodyOutput.style.opacity = '1';
            }
        }, 10);
    }
    showError(message) {
        if (!this.parodyOutput)
            return;
        this.parodyOutput.innerHTML = `<p class="error">${this.escapeHtml(message)}</p>`;
    }
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    handleCopy(button) {
        const codeBlock = button.parentElement?.querySelector('code');
        if (!codeBlock)
            return;
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
    initSmoothScroll() {
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                const href = e.currentTarget.getAttribute('href');
                if (!href || href === '#')
                    return;
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
    initScrollAnimations() {
        const observerOptions = {
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
        document.querySelectorAll('.feature-card, .step-card').forEach(card => {
            observer.observe(card);
        });
    }
    initTypingEffect() {
        const typingElements = document.querySelectorAll('.typing');
        typingElements.forEach((element, index) => {
            const text = element.textContent || '';
            element.textContent = '';
            element.classList.remove('typing');
            setTimeout(() => {
                this.typeText(element, text);
            }, index * 1000);
        });
    }
    initParallax() {
        let ticking = false;
        window.addEventListener('scroll', () => {
            if (!ticking) {
                window.requestAnimationFrame(() => {
                    const scrolled = window.pageYOffset;
                    const parallaxElements = document.querySelectorAll('.floating-circle');
                    parallaxElements.forEach((element, index) => {
                        const speed = 0.5 + (index * 0.1);
                        const yPos = -(scrolled * speed);
                        element.style.transform = `translateY(${yPos}px)`;
                    });
                    ticking = false;
                });
                ticking = true;
            }
        });
    }
    initSVGAnimations() {
        const svgIcons = document.querySelectorAll('.feature-icon svg');
        svgIcons.forEach(icon => {
            icon.addEventListener('mouseenter', () => {
                icon.classList.add('svg-hover');
            });
            icon.addEventListener('mouseleave', () => {
                icon.classList.remove('svg-hover');
            });
        });
        const logo = document.querySelector('.logo-icon');
        if (logo) {
            window.addEventListener('scroll', () => {
                const rotation = window.pageYOffset * 0.1;
                logo.style.transform = `rotate(${rotation}deg)`;
            });
        }
        this.initNavbarScroll();
    }
    initNavbarScroll() {
        const navbar = document.querySelector('.navbar');
        if (!navbar)
            return;
        let lastScroll = 0;
        window.addEventListener('scroll', () => {
            const currentScroll = window.pageYOffset;
            if (currentScroll > 50) {
                navbar.classList.add('scrolled');
            }
            else {
                navbar.classList.remove('scrolled');
            }
            lastScroll = currentScroll;
        });
    }
}
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        new YankovinatorUI();
    });
}
else {
    new YankovinatorUI();
}
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

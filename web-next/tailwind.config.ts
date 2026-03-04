import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: '#1A1A1A',
        accent: {
          DEFAULT: '#C6F135',
          dark: '#9BBF00',
          muted: '#F5FBDE',
        },
        onPrimary: '#FFFFFF',
        onAccent: '#1A1A1A',
        bg: '#FFFFFF',
        surface: {
          DEFAULT: '#F7F8F9',
          elevated: '#FFFFFF',
          tinted: '#FAFAFA',
        },
        text: {
          primary: '#1A1A1A',
          secondary: '#8E8E93',
          tertiary: '#AEAEB2',
          inverse: '#FFFFFF',
        },
        semantic: {
          error: '#FF3B30',
          'error-muted': '#FFF0EF',
          success: '#34C759',
          'success-muted': '#ECFDF3',
          warning: '#FF9500',
          'warning-muted': '#FFF8EC',
          info: '#007AFF',
          'info-muted': '#EBF5FF',
        },
        border: {
          DEFAULT: '#E5E5EA',
          subtle: '#F2F2F7',
          focus: '#1A1A1A',
        },
        price: {
          red: '#FF3B30',
          'accent-bg': '#C6F135',
        },
        shadow: {
          light: 'rgba(0,0,0,0.04)',
          medium: 'rgba(0,0,0,0.07)',
        },
      },
      spacing: {
        xs: '4px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        xl: '20px',
        '2xl': '24px',
        '3xl': '32px',
        '4xl': '48px',
      },
      borderRadius: {
        xs: '4px',
        sm: '8px',
        md: '12px',
        lg: '16px',
        full: '999px',
      },
      screens: {
        mobile: '600px',
        tablet: '960px',
      },
      maxWidth: {
        content: '960px',
        form: '560px',
        login: '400px',
        detail: '1080px',
        page: '1280px',
      },
      fontFamily: {
        sans: ['var(--font-noto-sans-kr)', 'system-ui', 'sans-serif'],
      },
      boxShadow: {
        card: '0 2px 8px rgba(0,0,0,0.04)',
        elevated: '0 4px 16px rgba(0,0,0,0.07)',
      },
    },
  },
  plugins: [],
};

export default config;

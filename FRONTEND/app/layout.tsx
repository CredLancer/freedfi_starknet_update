'use client';
import './globals.css';
import { ThemeProvider } from '../components/theme-provider';
import { Providers } from './providers';
import store from '@/store';
import { Provider as ReduxProvider } from 'react-redux';
import { StarknetProvider } from '@/components/starknet-provider';

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head />
      <body>
        <ReduxProvider store={store}>
          <ThemeProvider
            attribute="class"
            defaultTheme="system"
            enableSystem
            disableTransitionOnChange>
            <StarknetProvider>{children}</StarknetProvider>
          </ThemeProvider>
        </ReduxProvider>
      </body>
    </html>
  );
}

import '@rainbow-me/rainbowkit/styles.css';

import { Button } from '@/components/ui/button';
import { Avatar } from '@/components/ui/avatar';
import Link from 'next/link';
import { Poller_One } from 'next/font/google';
import { Sheet, SheetContent, SheetTrigger } from '../components/ui/sheet';
import { Menu, Moon, Sun } from 'lucide-react';
import { ConnectButton } from '@/components/StarknetConnectButton';

const poller_one = Poller_One({
  weight: ['400'],
  subsets: ['latin'],
});

export default function HeaderSection() {
  return (
    <div className="px-12 py-6">
      <div className="bg-white rounded-lg flex justify-between items-center px-6 py-4 shadow-sm border-grey border-[1px]">
        <div className="flex items-center">
          <Sheet>
            <SheetTrigger>
              <Menu className="h-6 md:hidden w-6" />
            </SheetTrigger>
            <SheetContent side="left" className="w-[300px] sm:w-[400px]">
              <nav className="flex flex-col gap-4">
                <Link href="/" className="block px-2 py-1 text-lg">
                  Home
                </Link>
                <Link href="/dashboard" className="block px-2 py-1 text-lg">
                  Dashboard
                </Link>
                <Link href="/add-contract" className="block px-2 py-1 text-lg">
                  Request Loan
                </Link>
              </nav>
            </SheetContent>
          </Sheet>
          <Link href="/" className="ml-4 lg:ml-0">
            <h1
              className={`text-xl active:scale-75 transition-all duration-200 font-bold ${poller_one.className}`}>
              FreedFi
            </h1>
          </Link>
        </div>

        <nav className="mx-4  items-center space-x-2 lg:space-x-4 hidden md:block">
          <Button asChild variant="ghost">
            <Link href="/" className="text-sm font-medium transition-colors">
              Home
            </Link>
          </Button>
          <Button asChild variant="ghost">
            <Link
              href="/dashboard"
              className="text-sm font-medium transition-colors">
              Dashboard
            </Link>
          </Button>
          <Button asChild variant="ghost" className="hover:bg-violet-500/10">
            <Link
              href="/add-contract"
              className="text-sm font-medium transition-colors">
              Request Loan
            </Link>
          </Button>
        </nav>

        <div className="flex items-center">
            <ConnectButton/>
        </div>
      </div>
    </div>
  );
}

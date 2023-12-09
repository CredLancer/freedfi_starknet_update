"use client";
import { Button } from '@/components/ui/button';
import { useAccount, useConnect, useDisconnect } from "@starknet-react/core";

function displaySubstring(str: string, lengthToShow: number): string {
    if (str.length <= lengthToShow * 2) {
        return str;
    }

    const firstPart = str.substring(0, lengthToShow);
    const lastPart = str.substring(str.length - lengthToShow);

    return `${firstPart}...${lastPart}`;
}

export function ConnectButton() {
    const { connect, connectors } = useConnect();
    const { account, address, isConnected, status } = useAccount();
    const { disconnect } = useDisconnect();

    return (
        <div>
        {isConnected ? (
            <Button onClick={() => disconnect()}>{address !== undefined && displaySubstring(address, 7)}</Button>
        ) : (
            <Button onClick={() => connect({connector: connectors[0]})}>Connect</Button>
        )}
        </div>
    );
    
  }
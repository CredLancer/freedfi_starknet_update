import React, { useState } from 'react';
import { Slider } from '@/components/ui/slider';
import { Poppins } from 'next/font/google';

const poppins = Poppins({
  weight: '400',
  subsets: ['latin'],
});

const SeekersProgress = ({ setLoanAmount, handleSliderChange, loanAmount }) => {
  return (
    <div>
      <h1 className="text-3xl font-bold text-center mb-2">
        Congratulations!🎉
      </h1>
      <p className="text-xl font-semibold text-center">
        Your score has increased.
      </p>
      <p className={`text-4xl ${poppins.className} text-center mt-6`}>
        Your Skill Match Score
      </p>
      <p
        className={`text-4xl ${poppins.className} bg-[#AF6DEA] text-center  text-white w-fit mx-auto`}>
        100%
      </p>
      <div className="mt-6 max-w-lg mx-auto">
        <Slider
          value={loanAmount} // Pass the array as the value
          onValueChange={handleSliderChange} // Use onValueChange instead of onChange
          max={20000}
          step={1}
        />
      </div>
      <div className="flex mt-8 gap-5 max-w-lg mx-auto justify-between">
        <p className="text-xl font-semibold uppercase">Your Loan Amount</p>
        <p className="px-4 py-2 border border-[#af6dea] rounded">
          $ {loanAmount[0]}
        </p>{' '}
        {/* Access the first element of the array */}
      </div>
    </div>
  );
};

export default SeekersProgress;

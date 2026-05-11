import React from 'react';
import { createClient } from '@/lib/superbase/server';
import { redirect } from "next/navigation";

const BuyNowLayout = async ({children,}: Readonly<{children: React.ReactNode;}>) => {

      const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return redirect("/login");
  }


  return (
    <div>
       {user && <div>{children}</div>}
    </div>
  )
}

export default BuyNowLayout;

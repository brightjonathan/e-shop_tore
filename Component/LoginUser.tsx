"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";

import { useState } from "react";
import toast from "react-hot-toast";



const LoginUser = () => {


    const [email, setEmail] = useState("");
    const [loading, setLoading] = useState(false);
    const [tokenPart, setTokenPart] = useState(false);
    const [token, setToken] = useState("");


    const router = useRouter();


    const handleLogin = async () => {
        //handles the login logic here
    }


  return (
    <div className="bg-black">
      <section className="flex flex-col justify-center h-screen items-center gap-6 text-white w-full px-4">
        {/* Logo */}
        <Link href={"/"}>
          <h1 className="text-4xl font-bold text-center">e-shop Store</h1>
        </Link>

        {/* Heading */}
        <h1 className="text-2xl md:text-2xl max-md:text-xl font-bold text-center">
          Please Provide Your Email
        </h1>

        {/* Input + Button */}
        <div className="w-full max-w-150 flex flex-col gap-4">
          <input
            onChange={(e) => setEmail(e.target.value)}
            placeholder="Your Email"
            name="email"
            type="email"
            id="Email"
            className="w-full px-4 py-3 bg-white rounded-lg transition-all duration-200 placeholder-gray-400 text-black shadow-sm"
          />
        </div>
        <button
        onClick={handleLogin}
          className="px-3 py-2 mt-4 text-sm font-medium tracking-wide text-white capitalize transition-colors duration-300  bg-[#043033] rounded-lg  focus:outline-none "
        >
          {loading ? "Signing In..." : "Sign In"}
        </button>
        <div className="flex flex-row justify-center align-center text-white">
          <p className="">We sign you up if you don&apos;t have an account? </p>
        </div>
      </section>
    </div>
  )
}

export default LoginUser

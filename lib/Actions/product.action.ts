"use server";

import { createClient } from "../superbase/server";
// import { ProductParams } from "@/shared.types";


export const fetchProducts = async () => { 
    const supabase = await createClient();
    const { data, error } = await supabase.from("products").select("*");
    if (error) {
        console.error("Error fetching products:", error);
        return [];
    }
    return data;
}
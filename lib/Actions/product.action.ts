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


export const fetchProductById = async (id: string) => {
     const supabase = await createClient();
  try {
    const { data: product, error } = await supabase
      .from("products")
      .select("*, category:categories(name)")
     //.select("*,category:categories!fk_category(name)")
      .eq("id", id)
      .single();

    if (error) {
      console.log(error);
      return null;
    }

    return product;
  } catch (error) {
    console.log(error);
    return null;
  }
}
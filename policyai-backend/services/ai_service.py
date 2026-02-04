import os
from google import genai
from google.genai import types

# Initialize client
try:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("⚠️ GEMINI_API_KEY not found in environment")
        AI_AVAILABLE = False
    else:
        client = genai.Client(api_key=api_key)
        AI_AVAILABLE = True
        print("✅ Gemini AI initialized successfully")
except Exception as e:
    AI_AVAILABLE = False
    print(f"⚠️ Gemini AI initialization failed: {e}")


def generate_policy_summary(title: str, description: str, category: str) -> str:
    """Generate AI-powered summary for policy using Gemini Flash"""
    
    if not AI_AVAILABLE:
        # Fallback: Simple truncation
        return description[:100] + "..." if len(description) > 100 else description
    
    try:
        # Create prompt for policy summary
        prompt = f"""You are a policy analyst. Generate a concise, neutral summary (40-50 words) of this policy proposal.

Policy Title: {title}
Category: {category}
Full Description: {description}

Summary (40-50 words, neutral tone):"""

        # Call Gemini 2.5 Flash (fastest, cheapest model)
        response = client.models.generate_content(
            model='gemini-1.5-flash',
            contents=prompt
        )
        
        summary = response.text.strip()
        print(f"✅ AI Summary generated: {summary[:50]}...")
        return summary
        
    except Exception as e:
        print(f"❌ AI Summary generation failed: {e}")
        # Fallback to simple truncation
        return description[:100] + "..." if len(description) > 100 else description


def analyze_policy_pros_cons(title: str, description: str) -> dict:
    """Analyze policy and generate pros/cons (Future feature)"""
    
    if not AI_AVAILABLE:
        return {"pros": [], "cons": [], "error": "AI not available"}
    
    try:
        prompt = f"""Analyze this policy proposal and provide:
1. Three main PROS (benefits/advantages)
2. Three main CONS (drawbacks/concerns)

Policy: {title}
Description: {description}

Format response as:
PROS:
1. [Pro 1]
2. [Pro 2]
3. [Pro 3]

CONS:
1. [Con 1]
2. [Con 2]
3. [Con 3]"""

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )
        
        # Parse response (you'll implement parsing logic)
        analysis_text = response.text.strip()
        
        return {
            "raw_analysis": analysis_text,
            "success": True
        }
        
    except Exception as e:
        print(f"❌ Policy analysis failed: {e}")
        return {"error": str(e), "success": False}

def analyze_policy_pros_cons(title: str, description: str, category: str) -> dict:
    """Generate AI-powered pros and cons analysis for policy"""
    
    if not AI_AVAILABLE:
        # Fallback: Generic response
        return {
            "pros": ["Addresses an important issue", "Could benefit citizens", "Shows policy initiative"],
            "cons": ["Implementation details unclear", "Funding sources not specified", "Timeline not defined"]
        }
    
    try:
        # Create prompt for pros/cons analysis
        prompt = f"""You are a policy analyst. Analyze this policy and provide exactly 3 PROS (benefits/advantages) and 3 CONS (concerns/drawbacks).

Policy Title: {title}
Category: {category}
Description: {description}

Format your response EXACTLY like this:
PROS:
1. [First benefit in one clear sentence]
2. [Second benefit in one clear sentence]
3. [Third benefit in one clear sentence]

CONS:
1. [First concern in one clear sentence]
2. [Second concern in one clear sentence]
3. [Third concern in one clear sentence]

Keep each point concise (10-15 words). Be balanced and objective."""

        # Call Gemini API
        response = client.models.generate_content(
            model='gemini-2.0-flash-exp',
            contents=prompt
        )
        
        analysis_text = response.text.strip()
        print(f"✅ AI Analysis generated for: {title[:50]}...")
        
        # Parse the response
        pros = []
        cons = []
        
        lines = analysis_text.split('\n')
        current_section = None
        
        for line in lines:
            line = line.strip()
            
            if 'PROS:' in line.upper():
                current_section = 'pros'
                continue
            elif 'CONS:' in line.upper():
                current_section = 'cons'
                continue
            
            # Extract numbered points
            if line and (line[0].isdigit() or line.startswith('-') or line.startswith('•')):
                # Remove numbering and clean up
                cleaned = line.lstrip('0123456789.-•) ').strip()
                
                if cleaned and current_section == 'pros':
                    pros.append(cleaned)
                elif cleaned and current_section == 'cons':
                    cons.append(cleaned)
        
        # Ensure we have exactly 3 of each
        pros = pros[:3] if len(pros) >= 3 else pros + ["Additional benefit needs analysis"] * (3 - len(pros))
        cons = cons[:3] if len(cons) >= 3 else cons + ["Additional concern needs analysis"] * (3 - len(cons))
        
        print(f"✅ Parsed {len(pros)} pros and {len(cons)} cons")
        
        return {
            "pros": pros,
            "cons": cons
        }
        
    except Exception as e:
        print(f"❌ AI Pros/Cons analysis failed: {e}")
        # Fallback
        return {
            "pros": ["Addresses an important issue", "Could benefit citizens", "Shows policy initiative"],
            "cons": ["Implementation details need clarity", "Funding sources require specification", "Timeline needs definition"]
        }

<%@ page import="java.io.*, java.net.*, org.json.JSONObject" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Currency Converter to INR</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        :root {
            --primary-color: #4CAF50;
            --primary-hover: #45a049;
            --text-color: #333;
            --light-gray: #f8f9fa;
            --border-color: #ddd;
            --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }
        
        body {
            font-family: 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', sans-serif;
            margin: 0;
            padding: 20px;
            background-color: var(--light-gray);
            color: var(--text-color);
            line-height: 1.6;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .converter-box {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            width: 100%;
            max-width: 450px;
            box-shadow: var(--shadow);
            transition: var(--transition);
        }
        
        h2 {
            color: var(--primary-color);
            margin-top: 0;
            margin-bottom: 1.5rem;
            text-align: center;
            font-weight: 600;
        }
        
        .form-group {
            margin-bottom: 1.5rem;
        }
        
        label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        input[type="number"] {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid var(--border-color);
            border-radius: 6px;
            font-size: 1rem;
            transition: var(--transition);
            box-sizing: border-box;
        }
        
        input[type="number"]:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(76, 175, 80, 0.2);
        }
        
        .radio-group {
            display: flex;
            flex-wrap: wrap;
            gap: 1rem;
        }
        
        .radio-option {
            display: flex;
            align-items: center;
            cursor: pointer;
            padding: 0.5rem 1rem;
            background-color: var(--light-gray);
            border-radius: 20px;
            transition: var(--transition);
        }
        
        .radio-option:hover {
            background-color: #e9ecef;
        }
        
        .radio-option input[type="radio"] {
            margin-right: 0.5rem;
        }
        
        button[type="submit"] {
            width: 100%;
            padding: 0.75rem;
            background-color: var(--primary-color);
            border: none;
            color: white;
            font-size: 1rem;
            font-weight: 500;
            border-radius: 6px;
            cursor: pointer;
            transition: var(--transition);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        button[type="submit"]:hover {
            background-color: var(--primary-hover);
            transform: translateY(-2px);
        }
        
        .result-container {
            margin-top: 1.5rem;
            padding: 1rem;
            border-radius: 6px;
            font-size: 1.1rem;
            text-align: center;
        }
        
        .success {
            background-color: #f0fff0;
            border-left: 4px solid var(--primary-color);
        }
        
        .error {
            background-color: #fff0f0;
            border-left: 4px solid #f44336;
        }
        
        .conversion-rate {
            font-size: 0.9rem;
            color: #666;
            margin-top: 0.5rem;
        }
        
        @media (max-width: 480px) {
            .converter-box {
                padding: 1.5rem;
            }
            
            .radio-group {
                flex-direction: column;
                gap: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="converter-box">
        <h2>Currency to INR Converter</h2>
        <form method="post">
            <div class="form-group">
                <label for="amount">Amount:</label>
                <input type="number" id="amount" name="amount" step="0.01" min="0" required>
            </div>
            
            <div class="form-group">
                <label>Convert from:</label>
                <div class="radio-group">
                    <label class="radio-option">
                        <input type="radio" name="from" value="USD" required> USD
                    </label>
                    <label class="radio-option">
                        <input type="radio" name="from" value="GBP"> GBP
                    </label>
                    <label class="radio-option">
                        <input type="radio" name="from" value="SGD"> SGD
                    </label>
                    <label class="radio-option">
                        <input type="radio" name="from" value="AUD"> AUD
                    </label>
                </div>
            </div>
            
            <button type="submit">Convert to INR</button>
        </form>

        <%
            String amountStr = request.getParameter("amount");
            String from = request.getParameter("from");
            String to = "INR"; // Always convert to INR

            if (amountStr != null && from != null) {
                try {
                    double amount = Double.parseDouble(amountStr);
                    String apiKey = "d0c2c7928f6a6a9976c5d3d5"; // Consider moving this to config
                    String apiUrl = "https://v6.exchangerate-api.com/v6/" + apiKey + "/latest/" + from;

                    URL url = new URL(apiUrl);
                    HttpURLConnection con = (HttpURLConnection) url.openConnection();
                    con.setRequestMethod("GET");
                    con.setConnectTimeout(5000);
                    con.setReadTimeout(5000);

                    int status = con.getResponseCode();
                    
                    if (status == 200) {
                        BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                        StringBuilder responseStr = new StringBuilder();
                        String inputLine;
                        while ((inputLine = in.readLine()) != null) {
                            responseStr.append(inputLine);
                        }
                        in.close();

                        JSONObject json = new JSONObject(responseStr.toString());
                        if (json.getString("result").equals("success")) {
                            JSONObject rates = json.getJSONObject("conversion_rates");
                            double rate = rates.getDouble(to);
                            double result = amount * rate;
        %>
                            <div class="result-container success">
                                <strong><%= amount %> <%= from %> = <%= String.format("%.2f", result) %> INR</strong>
                                <div class="conversion-rate">1 <%= from %> = <%= String.format("%.4f", rate) %> INR</div>
                            </div>
        <%
                        } else {
                            String errorInfo = json.optString("error-type", "Unknown error");
        %>
                            <div class="result-container error">
                                Failed to fetch exchange rate: <%= errorInfo %>
                            </div>
        <%
                        }
                    } else {
        %>
                        <div class="result-container error">
                            API Error: HTTP <%= status %>
                        </div>
        <%
                    }
                } catch (NumberFormatException e) {
        %>
                    <div class="result-container error">
                        Please enter a valid number
                    </div>
        <%
                } catch (SocketTimeoutException e) {
        %>
                    <div class="result-container error">
                        Request timed out. Please try again.
                    </div>
        <%
                } catch (Exception e) {
        %>
                    <div class="result-container error">
                        Error: <%= e.getMessage() %>
                    </div>
        <%
                }
            }
        %>
    </div>
</body>
</html>
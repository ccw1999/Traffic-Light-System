module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output          Gout;
output          Yout;
output          Rout;

reg             Gout;
reg             Yout;
reg             Rout;

reg         [3:0]G_ct;
reg         [3:0]Y_ct;
reg         [3:0]R_ct;

reg         [3:0]G_T;
reg         [3:0]Y_T;
reg         [3:0]R_T;

reg         [1:0]state;
reg         [1:0]next_state;

parameter   set_state = 2'd0;
parameter   G_S       = 2'd1;
parameter   Y_S       = 2'd2;
parameter   R_S       = 2'd3;

// Time
always @(posedge clk or posedge reset)
begin
    if (reset) 
        begin
            G_T <= 4'b0000;
            Y_T <= 4'b0000;
            R_T <= 4'b0000;
        end

    else if (Set)
        begin
            G_T <= Gin;
            Y_T <= Yin;
            R_T <= Rin;    
        end

    else 
        begin
            G_T <= G_T;
            Y_T <= Y_T;
            R_T <= R_T;
        end

end

// counter
always @(posedge clk)
begin
    if (reset || Set || Jump)
        begin
            G_ct <= 4'b0001;
            Y_ct <= 4'b0001;
            R_ct <= 4'b0001;
        end

    else if (Stop)
        begin
            G_ct <= G_ct;
            Y_ct <= Y_ct;
            R_ct <= R_ct;
        end

    else
        case(state)
            G_S :
                begin
                    G_ct <= G_ct + 1'b1;
                    Y_ct <= 4'b0001;
                    R_ct <= 4'b0001;
                end

            Y_S :   
                begin
                    G_ct <= 4'b0001;
                    Y_ct <= Y_ct + 1'b1;
                    R_ct <= 4'b0001;
                end

            R_S :   
                begin
                    G_ct <= 4'b0001;
                    Y_ct <= 4'b0001;
                    R_ct <= R_ct + 1'b1;
                end

            default: 
                begin
                    G_ct <= 4'b0001;
                    Y_ct <= 4'b0001;
                    R_ct <= 4'b0001;
                end

        endcase
end

// state register
always @(posedge clk or posedge reset) 
begin
    if (reset) state <= set_state;

    else state <= next_state;
end

// next state logic
always @(*) 
begin
    case(state)
        set_state : next_state = G_S;

        G_S :       if(Set) next_state = G_S;
                    else if(Jump) next_state = R_S;
                    else if(G_ct < G_T) next_state = G_S;
                    else if(Stop) next_state = G_S;
                    else     next_state = Y_S;

        Y_S :       if(Set) next_state = G_S;
                    else if(Jump) next_state = R_S;
                    else if(Y_ct < Y_T) next_state = Y_S;
                    else if(Stop) next_state = Y_S;
                    else     next_state = R_S;

        R_S :       if(Set) next_state = G_S;
                    else if(Jump) next_state = R_S;
                    else if(R_ct < R_T) next_state = R_S;
                    else if(Stop) next_state = R_S;
                    else     next_state = G_S;

        default :   next_state = set_state;

    endcase
end

// output logic
always @(*) 
begin
    case(state)

        G_S :   
            begin
                Gout = 1'b1;
                Yout = 1'b0;
                Rout = 1'b0;
            end

        Y_S :   
            begin
                Gout = 1'b0;
                Yout = 1'b1;
                Rout = 1'b0;
            end

        R_S :   
            begin
                Gout = 1'b0;
                Yout = 1'b0;
                Rout = 1'b1;
            end

        default :
            begin
                Gout = 1'b0;
                Yout = 1'b0;
                Rout = 1'b0;
            end

    endcase
end

endmodule